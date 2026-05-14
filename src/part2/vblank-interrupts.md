# VBlank interrupts

So far, we have waited for VBlank by repeatedly reading `rLY` until the PPU reaches line 144.
That works, but it keeps the CPU busy doing nothing useful.
The Game Boy can tell the CPU when VBlank begins instead, using the VBlank interrupt.

An interrupt is a request from the hardware to pause the code currently running, jump to a fixed address, run a small handler, then return to the paused code.
Each interrupt has an address called its *vector*.
The VBlank interrupt vector is `$0040`, and `hardware.inc` gives that address the name `INT_HANDLER_VBLANK`.

Let's add a handler for it above the `"Header"` section:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:vblank-interrupt}}
{{#include ../../unbricked/vblank-interrupts/main.asm:vblank-interrupt}}
```

The handler does two small jobs.
It marks that VBlank happened, and it increments our frame counter.

Notice the `push af` and `pop af`.
An interrupt can happen between any two instructions in our main code, so the handler must not leave CPU registers changed unexpectedly.
Here we only use `a` and the flags, so saving `af` is enough.
If a handler used more registers, it would need to save those too.
Finally, `reti` returns from the interrupt handler and allows interrupts again.

Next, add one byte next to `wFrameCounter`:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:variables}}
{{#include ../../unbricked/vblank-interrupts/main.asm:variables}}
```

The CPU will not jump to our handler until we enable interrupts.
After initializing our variables, clear any pending interrupt requests, enable the VBlank interrupt in `rIE`, then enable interrupt handling with `ei`.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:enable-vblank-interrupt}}
{{#include ../../unbricked/vblank-interrupts/main.asm:enable-vblank-interrupt}}
```

Now we can replace the `rLY` wait loop with a function:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:wait-for-vblank}}
{{#include ../../unbricked/vblank-interrupts/main.asm:wait-for-vblank}}
```

`halt` stops the CPU until an interrupt occurs.
This lets the CPU sleep instead of burning cycles in a loop.
The `nop` after `halt` is a harmless instruction to resume on, which is a common convention around `halt`.

The function clears `wVBlankDone`, sleeps, and then checks whether the VBlank handler set the byte back to 1.
This matters more once a program has more than one interrupt enabled: if some other interrupt wakes the CPU first, the function just waits again.

Finally, clean up the main loop:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:main}}
{{#include ../../unbricked/vblank-interrupts/main.asm:main}}
```

The frame counter is now updated by the interrupt handler, so the main loop no longer has to increment it manually.
This also makes the frame boundary explicit: each pass through the game logic starts after `WaitForVBlank` returns.

Up next, we will use that frame loop to read input once per frame.
