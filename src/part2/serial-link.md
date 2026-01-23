# Serial Link

In this lesson, we will:

- Learn how to control the Game Boy serial port from code;
- Build a wrapper over the low-level serial port interface;
- Implement checksums to verify data integrity and enable reliable data transfers.

## Running the code

Testing the code in this lesson (or any code that uses the serial port) is a bit more complicated than what we've been doing so far.
There's a few things to be aware of.

You need an emulator that supports the serial port, such as:
[Emulicious](https://emulicious.net/) and [GBE+](https://github.com/shonumi/gbe-plus).
The way this works is by having two instances of the emulator connect to each other over network sockets.

Keep in mind that the emulated serial port is never going to replicate the complexity and breadth of issues that can occur on the real thing.

Testing on hardware comes with hardware requirements, unfortunately.
You'll need two Game Boys (any combination of models), a link cable to connect them, and a pair of flash carts.


## The Game Boy serial port

:::tip Information overload

This section is intended as a reasonably complete description of the Game Boy serial port, from a programming perspective.
There's a lot of information packed in here and you don't need to absorb it all to continue.

:::

Communication via the serial port is organised as discrete data transfers of one byte each.
Data transfer is bidirectional, with every bit of data written out matched by one read in.
A data transfer can therefore be thought of as *swapping* the data byte in one device's buffer for the byte in the other's.

The serial port is *idle* by default.
Idle time is used to read received data, configure the port if needed, and load the next value to send.

Before we can transfer any data, we need to configure the *clock source* of both Game Boys.
To synchronise the two devices, one Game Boy must provide the clock signal that both will use.
Setting bit 0 of the [Serial Control register](https://gbdev.io/pandocs/Serial_Data_Transfer_(Link_Cable).html#ff02--sc-serial-transfer-control) (`rSC` as it's defined in hardware.inc) 
enables the Game Boy's *internal* serial clock, and makes it the clock provider.
The other Game Boy must have its clock source set to *external* (`SC` bit 0 cleared).
The externally clocked Game Boy will receive the clock signal via the link cable.

Before a transfer, the data to transmit is loaded into the **Serial Buffer** register (`SB`).
After a transfer, the `SB` register will contain the received data.

When ready, the program can set bit 7 of the `SC` register in order to *activate* the port -- instructing it to perform a transfer.
While the serial port is *active*, it sends and receives a data bit on each serial clock pulse.
After 8 pulses (*8 bits!*) the transfer is complete -- the serial port deactivates itself, and the serial interrupt is requested.
Normal execution continues while the serial port is active: the transfer will be performed independently of the program code.


## Sio

Alright, let's write some code!
**Sio** is the **S**erial **i**nput/**o**utput module and we're going to build it in its own file, so open a new file called `sio.asm`.

At the top of `sio.asm`, include `hardware.inc` and then define a set of constants that represent Sio's main states:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-status-enum}}
{{#include ../../unbricked/serial-link/sio.asm:sio-status-enum}}
```

Sio operates as a finite state machine with each of these constants being a unique state.
Sio's job is to manage serial transfers, so Sio's state simultaneously indicates what Sio is doing and the current transfer status.

:::tip EXPORT quality

`EXPORT` makes the variables following it available in other source files.
In general, there are better ways to do this -- it shouldn't be your first choice.
`EXPORT` is used here for simplicity, so we can stay focused on the concept being taught.

:::

Below the constants, add a new WRAM section with some variables for Sio's state:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-state}}
{{#include ../../unbricked/serial-link/sio.asm:sio-state}}
```

`wSioState` holds one of the state constants we defined above.
The other variables will be discussed as we build the features that use them.

Add a new code section and an initialisation routine:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-impl-init}}
{{#include ../../unbricked/serial-link/sio.asm:sio-impl-init}}
    ret
```


### Buffers
The buffers are a pair of temporary storage locations for all messages sent or received by Sio.
There's a buffer for data to transmit (Tx) and one for receiving data (Rx).
The variable `wSioBufferOffset` holds the current location within *both* data buffers -- Game Boy serial transfers are always symmetrical.

First we'll need a couple of constants, so add these below the existing ones, near the top of the file.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-buffer-defs}}
{{#include ../../unbricked/serial-link/sio.asm:sio-buffer-defs}}
```

Allocate the buffers, each in their own section, just above the `SioCore State` section we made earlier.
This needs to be specified carefully and uses some unfamiliar syntax, so you might like to copy and paste this code:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-buffers}}
{{#include ../../unbricked/serial-link/sio.asm:sio-buffers}}
```

`ALIGN[8]` causes each section -- and each buffer -- to start at an address with a low byte of zero.
This makes building a pointer to the buffer element at index `i` trivial, as the high byte of the pointer is constant for the entire buffer, and the low byte is simply `i`.
The result is a significant reduction in the amount of work required to access the data and manipulate offsets of both buffers.

:::tip Aligning Sections

If you would like to learn more about aligning sections -- *which is by no means required to continue this lesson* -- the place to start is the [SECTIONS](https://rgbds.gbdev.io/docs/rgbasm.5#SECTIONS) section in the rgbasm language documenation.

:::

At the end of `SioReset`, clear the buffers:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-reset-buffers}}
{{#include ../../unbricked/serial-link/sio.asm:sio-reset-buffers}}
```


### Core implementation
Below `SioInit`, add a function to start a multibyte transfer of the entire data buffer:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-start-transfer}}
{{#include ../../unbricked/serial-link/sio.asm:sio-start-transfer}}
```

To initialise the transfer, start from buffer offset zero, set the transfer count, and switch to the `SIO_ACTIVE` state.
The first byte to send is loaded from `wSioBufferTx` before a jump to the next function starts the first transfer immediately.

<!-- PortStart -->
Activating the serial port is a simple matter of setting bit 7 of `rSC`, but we need to do a couple of other things at the same time, so add a function to bundle it all together:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-port-start}}
{{#include ../../unbricked/serial-link/sio.asm:sio-port-start}}
```

The first thing `SioPortStart` does is something called the "catchup delay", but only if the internal clock source is enabled.

:::tip Delay? Why?

When a Game Boy serial port is active, it will transfer a data bit whenever it detects clock pulse.
When using the external clock source, the active serial port will wait indefinitely -- until the externally provided clock signal is received.
But when using the internal clock source, bits will start getting transferred as soon as the port is activated.
Because the internally clocked device can't wait once activated, the catchup delay is used to ensure the externally clocked device activates its port first.

:::

To check if the internal clock is enabled, read the serial port control register (`rSC`) and check if the clock source bit is set.
We test the clock source bit by *anding* with `SCF_SOURCE`, which is a constant with only the clock source bit set.
The result of this will be `0` except for the clock source bit, which will maintain its original value.
So we can perform a conditional jump and skip the delay if the zero flag is set.
The delay itself is a loop that wastes time by doing nothing -- `nop` is an instruction that has no effect -- a number of times.

To start the serial port, the constant `SCF_START` is combined with the clock source setting (still in `a`) and the updated value is loaded into the `SC` register.

Finally, the timeout timer is reset by loading the constant `SIO_TIMEOUT_TICKS` into `wSioTimer`.

:::tip Timeouts

We know that the serial port will remain active until it detects eight clock pulses, and performs eight bit transfers.
A side effect of this is that when relying on an *external* clock source, a transfer may never end!
This is most likely to happen if there is no other Game Boy connected, or if both devices are set to use an external clock source.
To avoid having this quirk become a problem, we implement *timeouts*: each byte transfer must be completed within a set period of time or we give up and consider the transfer to have failed.

:::

We'd better define the constants that set the catchup delay and timeout duration:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-port-start-defs}}
{{#include ../../unbricked/serial-link/sio.asm:sio-port-start-defs}}
```

<!-- Tick -->
Implement the timeout logic in `SioTick`:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-tick}}
{{#include ../../unbricked/serial-link/sio.asm:sio-tick}}
```

`SioTick` checks the current state (`wSioState`) and jumps to a state-specific subroutine (labelled `*_tick`).

**`SIO_ACTIVE`:** a transfer has been started, if the clock source is *external*, update the timeout timer.

The timer's state is an unsigned integer stored in `wSioTimer`.
Check that the timer is active (has a non-zero value) with `and a, a`.
Decrement the timer and write the new value back to memory.
If the timer expired (the new value is zero) the transfer should be aborted.
The `dec` instruction sets the zero flag in that case, so all we have to do is `jr z, SioAbort`.

**`SIO_RESET`:** `SioReset` has been called, change state to `SIO_IDLE`.
This causes a one tick delay after `SioReset` is called.

<!-- Abort -->
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-abort}}
{{#include ../../unbricked/serial-link/sio.asm:sio-abort}}
```

`SioAbort` brings the serial port down and sets the current state to `SIO_FAILED`.
The aborted transfer state is intentionally left intact so it can be used to instruct error handling and aid debugging.

<!-- PortEnd -->
The last part of the core implementation handles the end of each byte transfer:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-port-end}}
{{#include ../../unbricked/serial-link/sio.asm:sio-port-end}}
```

`SioPortEnd` starts by checking that a transfer was started (the `SIO_ACTIVE` state).
We're receiving a byte, so the transfer counter (`wSioCount`) is reduced by one.
The received value is copied from the serial port (`rSB`) to Sio's buffer (`wSioBufferRx`).
If there are still bytes to transfer (transfer counter is greater than zero) the next value is loaded from `wSioBufferTx` and the transfer is started by `SioPortStart`.
Otherwise, if the transfer counter is zero, enter the `SIO_DONE` state.


## Interval

So far we've written a bunch of code that, unfortunately, doesn't do anything on its own.
<sup><em>It works though, I promise!</em></sup>
The good news is that Sio -- the code that interfaces directly with the serial port -- is complete.

:::tip 🤖 Take a break!

Suggested break enrichment activity: CONSUME REFRESHMENT

Naturally, yours, &c.\,

A. Hughman

:::


## Reliable Communication

Sio by itself offers very little in terms of *reliability*.
For our purposes, reliability is all about dealing with errors.
The errors that we're concerned with are data replication errors -- any case where the data transmitted is not replicated correctly in the receiver.

<!-- Link/checksum -->
The first step is detection.
The receiver needs to test the integrity of every incoming data packet, before doing anything else with it.
We'll use a [checksum](https://en.wikipedia.org/wiki/Checksum) mechanism for this:
- The sender calculates a checksum of the outgoing packet and the result is transmitted as part of the packet transfer.
- The receiver performs the same calculation and compares the result with the value from the sender.
- If the values match, the packet is intact.

<!-- Link/protocol -->
With the packet integrity checksum, the receiving end can detect packet data corruption and discard packets that don't pass the test.
When a packet is not delivered successfully, it should be transmitted again by the sender.
Unfortunately, the sender has no idea if the packet it sent was delivered intact.

To keep the sender in the loop, and manage retransmission, we need a *protocol* -- a set of rules that govern communication.
The protocol follows the principle:
> The sender of a packet will assume the transfer failed, *unless the receiver reports success*.

Let's define two classes of packet:
- **Application Messages:** critical data that must be delivered, retransmit if delivery failed
    - contains application-specific data
- **Protocol Metadata:** do not retransmit (always send the latest state)
    - contains link state information (including last packet received)


:::tip Corruption? In my Game Boy?

Yep, there's any number of possible causes of transfer data replication errors when working with the Game Boy serial port.
Some examples include: old or damaged hardware, luck, [cosmic rays](https://en.wikipedia.org/wiki/Single-event_upset), and user actions (hostile and accidental).

:::


<!-- Link/handshake -->
There's one more thing our protocol needs: some way to get both devices on the same page and kick things off.
We need a *handshake* that must be completed before doing anything else.
This is a simple sequence that checks that there is a connection and tests that the connection is working.
The handshake can be performed in one of two roles: *A* or *B*.
To be successful, one peer must be *A* and the other must be *B*.
Which role to perform is determined by the clock source setting of the serial port.
The handshake then involves a number of exchanges, with each peer sending a certain value that the other expects.
If an unexpected value is received, or something goes wrong with the transfer, that handshake is rejected.


## SioPacket

SioPacket is a thin layer over Sio buffer transfers.
- The most important addition is a checksum based integrity test.
- Several convenience routines are also provided.

Packets fill a Sio buffer with the following structure:
```rgbasm
PacketLayout:
    .start_mark: db               ; The constant SIO_PACKET_START.
    .checksum: db                 ; Packet checksum, set before transmission.
    .data: ds SIO_BUFFER_SIZE - 2 ; Packet data (user defined).
    ; Unused space in .data is filled with SIO_PACKET_END.
```

At the top of `sio.asm` define some constants:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-packet-defs}}
{{#include ../../unbricked/serial-link/sio.asm:sio-packet-defs}}
```

`SioPacketTxPrepare` creates a new empty packet in the Tx buffer:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-packet-prepare}}
{{#include ../../unbricked/serial-link/sio.asm:sio-packet-prepare}}
```

- The checksum is set to zero for the initial checksum calculation.
- The data section is cleared by filling it with the constant `SIO_PACKET_END`.

After calling `SioPacketTxPrepare`, the payload data can be written to the packet.
Then, the function `SioPacketTxFinalise` should be called:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-packet-finalise}}
{{#include ../../unbricked/serial-link/sio.asm:sio-packet-finalise}}
```

- Call `SioPacketChecksum` to calculate the packet checksum.
    - It's important that the value of the checksum field is zero when performing this initial checksum calculation.
- Write the correct checksum to the packet header.
- Start the transfer.


Implement the packet integrity test for received packets:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-packet-check}}
{{#include ../../unbricked/serial-link/sio.asm:sio-packet-check}}
```

- Check that the packet begins with the magic number `SIO_PACKET_START`.
- Calculate the checksum of the received data.
    - This includes the packet checksum calculated by the sender.
    - The result of this calculation will be zero if the data is the same as it was when sent.

Finally, implement the checksum:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/sio.asm:sio-checksum}}
{{#include ../../unbricked/serial-link/sio.asm:sio-checksum}}
```

- start with the size of the buffer (effectively -1 for each byte summed)
- subtract each byte in the buffer from the sum

:::tip

The checksum implemented here has been kept very simple for this tutorial.
It's probably worth looking into better solutions for real-world projects.

Check Ben Eater's lessons on [Reliable Data Transmission](https://www.youtube.com/watch?v=eq5YpKHXJDM),
[Error Detection: Parity Checking](https://www.youtube.com/watch?v=MgkhrBSjhag), [Checksums and Hamming Distance](https://www.youtube.com/watch?v=ppU41c15Xho),
[How Do CRCs Work?](https://www.youtube.com/watch?v=izG7qT0EpBw) to explore further this topic.

:::


## Connecting it all together
It's time to implement the protocol and build the application-level features on top of everything we've done so far.

<!-- Link defs -->
At the top of main.asm, define the constants for keeping track of Link's state:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-defs}}
{{#include ../../unbricked/serial-link/main.asm:link-defs}}
```

<!-- Link state -->
We'll need some variables in WRAM to keep track of things.
Add a section at the bottom of main.asm:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-state}}
{{#include ../../unbricked/serial-link/main.asm:link-state}}
```

- these will make more sense as we use them, but ...
- `wLink` holds the state/status of the Link feature itself.
    - the constants prefixed with `LINK_` correspond to `wLink`
- `wShakeFailed` is used to indicate handshake failure, and to delay (re-)connection attempts

<!-- FIX: Doesn't match the unbricked link feature.
`wLocal` and `wRemote` are two identical structures for storing the Link state information of each peer.
- `state` holds the current mode and some flags (the `LINKST_` constants)
- `tx_id` & `rx_id` are for the IDs of the most recently sent & received `MSG_DATA` message

The contents of application data messages (`MSG_DATA` only) will be stored in the buffers `wTxData` and `wRxData`.

`wAllowTxAttempts` is the number of transmission attempts remaining for each DATA message.
`wAllowRxFaults` is the "budget" of delivery faults allowed before causing an error.
-->


### LinkInit
We're going to add quite a few functions for the new link feature and they'll all be prefixed with `Link`.
To keep things organised, add a new `ROM0` section for the `Link` implementation:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl}}
{{#include ../../unbricked/serial-link/main.asm:link-impl}}
```

First things first: we need to initialise the variables we created, as well as Sio, so create the `LinkInit` function:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-init}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-init}}
```

After calling `SioInit` this enables something called the *serial interrupt* by setting the associated bit (`IEF_SERIAL`) of the `rIE` register.


### Serial Interrupt
Sio needs to be told when to process each completed byte transfer.
The best way to do this is by using the serial interrupt.
Copy this code (it needs to be exact) to `main.asm`, just above the `"Header"` section:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:serial-interrupt-vector}}
{{#include ../../unbricked/serial-link/main.asm:serial-interrupt-vector}}
```

A proper and complete explanation of this is beyond the scope of this lesson.
You can continue the lesson understanding that:
- This is the serial interrupt handler. It gets called automatically after each serial transfer.
- The significant implementation is in `SioPortEnd` but it's necessary to jump through some hoops to call it.

A detailed and rather dense explanation is included for completeness.

:::tip

*You can just use the code as explained above and skip past this box.*

An interrupt handler is a piece of code at a specific address that gets called automatically under certain conditions.
The serial interrupt handler begins at address `$58` so a section just for this function is defined at that location using `ROM0[$58]`.
Note that the function is labelled by convention and for debugging purposes -- it isn't technically meaningful and the function isn't intended to be called manually.

Whatever code was running when an interrupt occurs literally gets paused until the interrupt handler returns.
The registers used by `SioPortEnd` need to be preserved so the code that got interrupted doesn't break.
We use the stack to do this -- using `push` before the call and `pop` afterwards.
Note that the order of the registers when pushing is the opposite of the order when popping, due to the stack being a LIFO (last-in, first-out) container.

`reti` returns from the function (like `ret`) and enables interrupts (like `ei`) which is necessary because interrupts are disabled automatically when calling an interrupt handler.

If you would like to continue digging, have a look at [evie's interrupts tutorial](https://evie.gbdev.io/resources/interrupts) and Pan Docs page on [Interrupts](https://gbdev.io/pandocs/Interrupts.html).

:::


### LinkUpdate
`LinkUpdate` is the main per-frame update function for the link feature.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-update}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-update}}
```

To follow the code here, it helps to see the whole thing as a state machine.

- `LINK_ENABLE` flag controls the entire feature
    - if its not set, do nothing
- update Sio:
    - `SioTick` needs to be called regularly, so we do that here
    - check `wSioState` -- if Sio is waiting for a transfer to complete, we wait too.
- the `LINK_CONNECTED` flag is set once we've successfully performed a handshake
    - jump to `.conn_up:` if the flag is set
        - check `wSioState` to decide what to do
        - the implementation of each of these functions is below
    - otherwise, continue into `.conn_shake:` to perform a handshake
        - `wShakeFailed` is set non-zero when a handshake fails -- the value acts as a countdown timer to delay retry attempts
            - decrement it (`dec a`) and store the new value
            - if the new value is zero, jump to `LinkStart` to try again
        - if `wShakeFailed` is zero, a handshake attempt is already underway
            - check `wSioState` to decide what to do
            - the implementation of each of these functions is below


#### LinkPacketRx
`LinkPacketRx` is used to check for and validate received packets from any state.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-packet-rx}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-packet-rx}}
```

The first thing to do is flush Sio's state (set it to `SIO_IDLE`) to indicate that the received data has been processed.
Technically the data hasn't actually been processed yet, but this is a promise to do that!

Check that a packet was received and that it arrived intact by calling `SioPacketRxCheck`.
Return here if Sio's checks failed.

The last part checks that the received packet count matches the local one in `wLinkPacketCount`.
This is done to check that both peers are in sync.

Note that `LinkPacketRx` uses the zero flag to return a status code.

:::tip

Actually we test against `wLinkPacketCount` minus one (`dec a`) because the value stored is the number of packets *sent*.

:::


#### Sending messages
`LinkShakeTx` and `LinkGameTx` are quite simple and work in the same way.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-shake-tx}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-shake-tx}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-game-tx}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-game-tx}}
```

To send a packet:
1. `call SioPacketTxPrepare`,
2. write the data to the packet buffer (`HL` was set by Sio),
3. `call SioPacketTxFinalise`.

The contents of the packet
- the packet sequence ID / count (value of `wLinkPacketCount`)
    - required to pass the check in `LinkPacketRx`
- one of the `MSG_*` constants
- message-specific data, if any
    - `MSG_GAME` includes the local score (`wScore`)
    - `MSG_SHAKE` has none


#### Completing the handshake
`LinkShakeRx` is responsible for completing the handshake.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-shake-rx}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-shake-rx}}
```

- `LinkPacketRx`
- check that received MSG_SHAKE
- handshake is complete when `wLinkPacketCount` reaches three
    - as in 3 handshake packets have been sent & received successfully
- set the `LINK_CONNECTED` flag if handshake is complete


#### Handshake failure
`LinkShakeFail` ends the handshake attempt in failure.
This is called when a Sio transfer fails during the handshake and when an invalid handshake message is received.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-shake-fail}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-shake-fail}}
```

Set `wShakeFailed` to a non-zero to indicate failure.
The value used depends on the clock source setting of the serial port.

- this is part of the automatic role selection strategy
- because the clock provider transfers will occur immediately...
- makes it more likely that (after a failed handshake) the externally clocked device will enable its serial port before the clock provider does.


#### LinkGameRx

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-game-rx}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-game-rx}}
```


#### LinkStop

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-stop}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-stop}}
```


#### LinkStart
`LinkStart` starts a new handshake attempt.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-impl-start}}
{{#include ../../unbricked/serial-link/main.asm:link-impl-start}}
```

The handshake can be forced to restart in the clock provider role by holding START.
This is included as a fallback and manual override for the automatic role selection described below.

To automatically determine which device should be the clock provider, we could use a random number generator, but we don't have one, so we'll just check the lowest bit of the DIV register.
The value in DIV is automatically incremented at around 16 kHz, which is not at all random, but all we really need is a single bit that's unlikely to be the same as the one on the remote device.

:::tip DIV is a Pretend Random Number Generator

Not to be confused with a [Pseudorandom Number Generator](https://en.wikipedia.org/wiki/Pseudorandom_number_generator).

:::


### Finally!
To integrate the link feature, make some changes to the main loop and entry point:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-main}}
{{#include ../../unbricked/serial-link/main.asm:link-main}}
```

- Call `LinkInit` at startup, just before the `Main:` loop.
- In the main loop,
    - call `LinkUpdate`
    - `ei`/`di` & code to update the display
        - display remote score, & a serial port status icon
    - check `wLink` status & skip ball update if not connected
        - freezes the game if not connected

Copy this function, which is used to to display the remote score (which is a BCD number).
You don't need to pay attention to this, it just adapts printing code from the BCD lesson.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-print-bcd}}
{{#include ../../unbricked/serial-link/main.asm:link-print-bcd}}
```
Copy these new tiles to the end of the tile data -- they should be immediately after the digits, right before `TilesEnd`.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-tiles}}
{{#include ../../unbricked/serial-link/main.asm:link-tiles}}
```


## Running the test ROM
The build commands are as follows to build both `main.asm` and `sio.asm` into a single ROM (see [Title Screen](./title-screen.md)):

```console
$ rgbasm -o sio.o sio.asm
$ rgbasm -o main.o main.asm
$ rgblink -o unbricked.gb main.o sio.o
$ rgbfix -v -p 0xFF unbricked.gb
```

