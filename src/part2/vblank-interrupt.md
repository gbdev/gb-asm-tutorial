# VBlank Interrupt

In the previous chapter, we waited for VBlank by repeatedly reading `rLY`.
That works, but it keeps the CPU busy doing nothing for most of the frame.
The Game Boy can notify us when VBlank starts instead: this is what the VBlank interrupt is for.

An interrupt is a small function that the CPU jumps to automatically when some hardware event happens.
For VBlank, that function must live at address `$40`.
Add this before the header:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupt/main.asm:vblank-interrupt}}
{{#include ../../unbricked/vblank-interrupt/main.asm:vblank-interrupt}}
```

The handler only marks that VBlank happened, then returns with `reti`.
We save and restore `af` because interrupts can happen between two unrelated instructions, and the interrupted code should not see its registers unexpectedly changed.

We need one byte of RAM for that mark, next to the frame counter we already added:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupt/main.asm:variables}}
{{#include ../../unbricked/vblank-interrupt/main.asm:variables}}
```

After the LCD is on and our variables are initialized, enable the VBlank interrupt:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupt/main.asm:enable-vblank-interrupt}}
{{#include ../../unbricked/vblank-interrupt/main.asm:enable-vblank-interrupt}}
```

`rIE` chooses which interrupts are allowed to run, and `ei` enables interrupt handling globally.
Clearing `rIF` first discards any old pending interrupt request so our first wait starts from a known state.

Now we can replace the `rLY` polling at the top of the main loop with a function:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupt/main.asm:wait-vblank}}
{{#include ../../unbricked/vblank-interrupt/main.asm:wait-vblank}}
```

`halt` stops the CPU until an enabled interrupt fires.
When VBlank starts, the handler above sets `wVBlankFlag`, `halt` returns, and the loop can safely update OAM for this frame.

With that helper in place, the main loop starts like this:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupt/main.asm:main-loop-start}}
{{#include ../../unbricked/vblank-interrupt/main.asm:main-loop-start}}
```

The rest of the loop is the same game logic as before, but the CPU is not wasting the visible part of the frame in a busy loop.
Later, when we add more interrupts, this flag check will also make sure we only continue when the interrupt that woke us was actually VBlank.
