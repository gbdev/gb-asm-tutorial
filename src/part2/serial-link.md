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
Setting bit 0 of the **Serial Control** register (`SC`) enables the Game Boy's *internal* serial clock, and makes it the clock provider.
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
In each exchange, each peer sends a number associated with its role and expects to receive a number associated with the other role.
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

:::


## Connecting it all together
It's time to implement the protocol and build the application-level features on top of everything we've done so far.

<!-- Link defs -->
At the top of main.asm, define the constants for keeping track of Link's state:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:serial-demo-defs}}
{{#include ../../unbricked/serial-link/main.asm:serial-demo-defs}}
```

<!-- Link state -->
We'll need some variables in WRAM to keep track of things.
Add a section at the bottom of main.asm:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:serial-demo-wram}}
{{#include ../../unbricked/serial-link/main.asm:serial-demo-wram}}
```

`wLocal` and `wRemote` are two identical structures for storing the Link state information of each peer.
- `state` holds the current mode and some flags (the `LINKST_` constants)
- `tx_id` & `rx_id` are for the IDs of the most recently sent & received `MSG_DATA` message

The contents of application data messages (`MSG_DATA` only) will be stored in the buffers `wTxData` and `wRxData`.

`wAllowTxAttempts` is the number of transmission attempts remaining for each DATA message.
`wAllowRxFaults` is the "budget" of delivery faults allowed before causing an error.


### LinkInit
Lots of variables means lots of initialisation so let's add a function for that:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-init}}
{{#include ../../unbricked/serial-link/main.asm:link-init}}
```

This initialises Sio by calling `SioInit` and then enables something called the serial interrupt which will be explained soon.
Execution continues into `LinkReset`.

`LinkReset` can be called to reset the whole Link feature if something goes wrong.
This resets Sio and then writes default values to all the variables we defined above.
Finally, a function called `HandshakeDefault` is jumped to and for that one you'll have to wait a little bit!

Make sure to call the init routine once before the main loop starts:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:serial-demo-init-callsite}}
{{#include ../../unbricked/serial-link/main.asm:serial-demo-init-callsite}}
```

We'll also add a utility function for handling errors:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-error-stop}}
{{#include ../../unbricked/serial-link/main.asm:link-error-stop}}
```


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
- The relevant stuff is in `SioPortEnd` but it's necessary to jump through some hoops to call it.

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
`LinkUpdate` is the main per-frame update function.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-update}}
{{#include ../../unbricked/serial-link/main.asm:link-update}}
```

The order of each part of this is important -- note the many (conditional) places where execution can exit this procedure.

Check input before anything else so the user can always reset the demo.

The `LINKST_MODE_ERROR` mode is an unrecoverable error state that can only be exited via the reset.
To check the current mode, read the `wLocal.state` byte and use `and a, LINKST_MODE` to keep just the mode bits.
There's nothing else to do in the `LINKST_MODE_ERROR` mode, so simply return from the function if that's the case.

Update Sio by calling `SioTick` and then call a specific function for the current mode.

`LINKST_MODE_CONNECT` manages the handshake process.
Update the handshake if it's incomplete (`wHandshakeState` is non-zero).
Otherwise, transition to the active connection mode.

`LINKST_MODE_UP` just checks the current state of the Sio state machine in order to jump to an appropriate function to handle certain cases.


### LinkTx
`LinkTx` builds the next message packet and starts transferring it.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-send-message}}
{{#include ../../unbricked/serial-link/main.asm:link-send-message}}
```

There's two types of message that are sent while the link is active -- SYNC and DATA.
The `LINKST_STEP_SYNC` flag is used to alternate between the two types and ensure at least every second message is a SYNC.
A DATA message will only be sent if the `LINKST_STEP_SYNC` flag is clear and the `LINKST_TX_ACT` flag is set.

Both cases then send a packet in much the same way -- `call SioPacketPrepare`, write the data to the packet (starting at `HL`), and then `call SioPacketFinalise`.

To make sending DATA messages more convenient, add a utility function to take care of the details:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-tx-start}}
{{#include ../../unbricked/serial-link/main.asm:link-tx-start}}
```


### LinkRx
When a transfer has completed (`SIO_DONE`), process the received data in `LinkRx`:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:link-receive-message}}
{{#include ../../unbricked/serial-link/main.asm:link-receive-message}}
```

The first thing to do is flush Sio's state (set it to `SIO_IDLE`) to indicate that the received data has been processed.
Technically the data hasn't actually been processed yet, but this is a promise to do that!

Check that a packet was received and that it arrived intact by calling `SioPacketRxCheck`.
If the packet checks out OK, read the message type from the packet data and jump to the appropriate routine to handle messages of that type.

<!-- Faults -->
If the result of `SioPacketRxCheck` was negative, or the message type is unrecognised, it's considered a delivery *fault*.
In case of a fault, the received data is discarded and the fault counter is updated.
The fault counter state is loaded from `wAllowRxFaults`.
If the value of the counter is zero (i.e. there's zero (more) faults allowed) the error mode is acivated.
If the value of the counter is more than zero, it's decremented and saved.

<!-- SYNC -->
`MSG_SYNC` messages contain the sender's Link state, so first we copy the received data to `wRemote`.
Now we want to check if the remote peer has acknowledged delivery of a message sent to them.
Copy the new `wRemote.rx_id` value to register `B`, then load `wLocal.state` and copy it into register `C`
Check the `LINKST_TX_ACT` flag (using the `and` instruction) and return if it's not set.
Otherwise, an outgoing message has not been acknowledged yet, so load `wLocal.tx_id` and compare it to `wRemote.rx_id` (in register `B`).
If the two are equal that means the message was delivered, so clear the `LINKST_TX_ACT` flag and update `wLocal.state`.

<!-- DATA -->
Receiving `MSG_DATA` messages is straightforward.
The first byte is the message ID, so copy that from the packet to `wLocal.rx_id`.
The rest of the packet data is copied straight to the `wRxData` buffer.
Finally, a flag is set to indicate that data was newly received.


### Main

Demo update routine:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:serial-demo-update}}
{{#include ../../unbricked/serial-link/main.asm:serial-demo-update}}
```

Call the update routine from the main loop:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:serial-demo-update-callsite}}
{{#include ../../unbricked/serial-link/main.asm:serial-demo-update-callsite}}
```


### Implement the handshake protocol

/// Establish contact by trading magic numbers

/// Define the codes each device will send:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:handshake-codes}}
{{#include ../../unbricked/serial-link/main.asm:handshake-codes}}
```

///
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:handshake-state}}
{{#include ../../unbricked/serial-link/main.asm:handshake-state}}
```

/// Routines to begin handshake sequence as either the internally or externally clocked device.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:handshake-begin}}
{{#include ../../unbricked/serial-link/main.asm:handshake-begin}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:handshake-update}}
{{#include ../../unbricked/serial-link/main.asm:handshake-update}}
```

The handshake can be forced to restart in the clock provider role by pressing START.
This is included as a fallback and manual override for the automatic role selection implemented below.

If a transfer is completed, process the received data by jumping to `HandshakeMsgRx`.

If the serial port is otherwise inactive, (re)start the handshake.
To automatically determine which device should be the clock provider, we check the lowest bit of the DIV register.
This value increments at around 16 kHz which, for our purposes and because we only check it every now and then, is close enough to random.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/serial-link/main.asm:handshake-xfer-complete}}
{{#include ../../unbricked/serial-link/main.asm:handshake-xfer-complete}}
```

Check that a packet was received and that it contains the expected handshake value.
The state of the serial port clock source bit is used to determine which value to expect -- `SHAKE_A` if set to use an external clock and `SHAKE_B` if using the internal clock.
If all is well, decrement the `wHandshakeState` counter.
If the counter is zero, there is nothing left to do.
Otherwise, more exchanges are required so start the next one immediately.

:::tip

This is a trivial example of a handshake protocol.
In a real application, you might want to consider:
- using a longer sequence of codes as a more unique app identifier
- sharing more information about each device and negotiating to decide the preferred clock provider

:::



## /// Running the test ROM

/// Because we have an extra file (sio.asm) to compile now, the build commands will look a little different:
```console
$ rgbasm -o sio.o sio.asm
$ rgbasm -o main.o main.asm
$ rgblink -o unbricked.gb main.o sio.o
$ rgbfix -v -p 0xFF unbricked.gb
```
