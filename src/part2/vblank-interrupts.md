# VBlank Interrupts

So far, Unbricked waits for the next frame by reading `rLY` in a loop until the Game Boy reaches VBlank.
That works, but the CPU is awake for the whole wait.
The Game Boy can do better: it can trigger an interrupt at the start of VBlank, wake the CPU, and let our main loop run once per frame.

This chapter keeps the game logic the same, but changes the frame timing code to use the VBlank interrupt.

## Why VBlank?

The LCD controller draws the visible screen from lines 0 through 143.
After that, lines 144 through 153 are the VBlank period.
This is the safest time to update video-related data such as OAM and some VRAM contents, because the PPU is not drawing visible pixels.

In the previous chapters we waited for this period with code like this:

```rgbasm
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank
```

That loop constantly checks the current scanline.
Instead, we can let the VBlank interrupt tell us when a new frame starts.

## The interrupt handler

The VBlank interrupt handler must live at address `$0040`, which is the VBlank interrupt vector.
Each interrupt source has its own vector, or fixed address where the CPU begins running when that interrupt is handled.
For now, all it needs to do is set a flag that our main loop can check.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:vblank-interrupt}}
{{#include ../../unbricked/vblank-interrupts/main.asm:vblank-interrupt}}
```

The handler uses `push af` and `pop af` because it changes the `a` register.
Interrupts can happen between two instructions in your main program, so an interrupt handler should preserve any registers it changes before returning.
The stack is the usual place to save those registers temporarily.
If a handler later uses `bc`, `de`, or `hl`, it should save and restore those too.

Notice the `reti` instruction at the end.
It works like `ret`, but also tells the CPU that the interrupt handler is finished.

## Enabling VBlank interrupts

Next, reserve one byte of RAM for the flag:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:ram}}
{{#include ../../unbricked/vblank-interrupts/main.asm:ram}}
```

Before entering the main loop, clear the flag, clear any pending interrupt request, enable the VBlank interrupt, and finally allow interrupts globally:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:enable-vblank-interrupt}}
{{#include ../../unbricked/vblank-interrupts/main.asm:enable-vblank-interrupt}}
```

`rIF` stores pending interrupt requests, while `rIE` chooses which interrupt sources are allowed to wake the CPU.
Here we enable only `IE_VBLANK`.

## Waiting without a busy loop

Now we can replace the old scanline polling inside `Main` with a function call:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:momentum}}
{{#include ../../unbricked/vblank-interrupts/main.asm:momentum}}
```

Here is the wait function:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/vblank-interrupts/main.asm:wait-for-vblank}}
{{#include ../../unbricked/vblank-interrupts/main.asm:wait-for-vblank}}
```

The important instruction is `halt`.
When interrupts are enabled, `halt` puts the CPU to sleep until an enabled interrupt occurs.
The VBlank handler sets `wVBlankFlag`, the CPU wakes up, and the wait function clears the flag before returning.

The first check handles the case where VBlank already happened before we called `WaitForVBlank`.
That way the game does not accidentally sleep through a frame.

## What this does and does not solve

This change gives Unbricked a better frame clock.
The main loop now starts from the VBlank interrupt instead of repeatedly polling `rLY`, so the timing code no longer sits in a scanline busy loop.

It does not introduce shadow OAM or OAM DMA yet.
Those are the usual next steps once a game has more sprites, because they let you prepare sprite data in RAM during the frame and copy it to hardware OAM during VBlank.
For this small example, the direct OAM writes are still easy to follow, and the interrupt-based frame timing is a good next step toward that structure.

Try compiling the new example:

```console
cd unbricked/vblank-interrupts
bash build.sh
```

The game should behave the same as before, but its main loop now waits for VBlank by sleeping until the interrupt fires.
