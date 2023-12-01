# Jumps

:::tip

Once this lesson is done, we will be able to understand all of `CopyTiles`!

:::

So far, all the code we have seen was linear: it executes top to bottom.
But this doesn't scale: sometimes, we need to perform certain actions depending on the result of others ("if the crêpes start sticking, grease the pan again"), and sometimes, we need to perform actions repeatedly ("If there is some batter left, repeat from step 5").

Both of these imply reading the recipe non-linearly.
In assembly, this is achieved using *jumps*.

The CPU has a special-purpose register called "PC", for Program Counter.
It contains the address of the instruction currently being executed[^pc_updates], like how you'd keep in mind the number of the recipe step you're currently doing.
PC increases automatically as the CPU reads instructions, so "by default" they are read sequentially; however, jump instructions allow writing a different value to PC, effectively *jumping* to another piece of the program.
Hence the name.

Okay, so, let's talk about those jump instructions, shall we?
There are four of them:

Instruction   | Mnemonic | Effect
--------------|----------|---------------------------------------------
Jump          | `jp`     | Jump execution to a location
Jump Relative | `jr`     | Jump to a location close by
Call          | `call`   | Call a subroutine
Return        | `ret`    | Return from a subroutine

We will focus on `jp` for now.
`jp`, such as the one line {{#line_no_of "^\s*jp" ../assets/hello-world.asm}}, simply sets PC to its argument, jumping execution there.
In other words, after executing `jp EntryPoint` (line {{#line_no_of "^\s*jp EntryPoint" ../assets/hello-world.asm}}), the next instruction executed is the one below `EntryPoint` (line <!-- should be {{#line_no_of "^\s*EntryPoint:" ../assets/hello-world.asm}} + 1 --> 16).

:::tip:🤔

You may be wondering what is the point of that specific `jp`.
Don't worry, we will see later why it's required.

:::

## Conditional jumps

Now to the *really* interesting part.
Let's examine the loop responsible for copying tiles:

```rgbasm,linenos,start={{#line_no_of "" ../assets/hello-world.asm:memcpy}}
{{#include ../assets/hello-world.asm:memcpy}}
```

:::tip

Don't worry if you don't quite get all the following, as we'll see it live in action in the next lesson.
If you're having trouble, try going to the next lesson, watch the code execute step by step; then, coming back here, it should make more sense.

:::

First, we copy `Tiles`, the address of the first byte of tile data, into `de`.
Then, we set `hl` to $9000, which is the address where we will start copying the tile data to.
`ld bc, TilesEnd - Tiles` sets `bc` to the length of the tile data: `TilesEnd` is the address of the first byte *after* the tile data, so subtracting `Tiles` to that yields the length.

So, basically:

- `de` contains the address where data will be copied from;
- `hl` contains the address where data will be copied to;
- `bc` contains how many bytes we have to copy.

Then we arrive at the main loop.
We read one byte from the source (line {{#line_no_of "^\s*ld a, \[de\]" ../assets/hello-world.asm:memcpy}}), and write it to the destination (line {{#line_no_of "^\s*ld \[hli\], a" ../assets/hello-world.asm:memcpy}}).
We increment the destination (via the implicit `inc hl` done by `ld [hli], a`) and source pointers (line {{#line_no_of "^\s*inc de" ../assets/hello-world.asm:memcpy}}), so the following loop iteration processes the next byte.

Here's the interesting part: since we've just copied one byte, that means we have one less to go, so we `dec bc`.
(We have seen `dec` two lessons ago; as a refresher, it simply decreases the value stored in `bc` by one.)
Since `bc` contains the amount of bytes that still need to be copied, it's trivial to see that we should simply repeat the operation if `bc` != 0.

:::danger:😓

`dec` usually updates flags, but unfortunately `dec bc` doesn't, so we must check if `bc` reached 0 manually.

:::

`ld a, b` and `or a, c` "bitwise OR" `b` and `c` together; it's enough to know for now that it leaves 0 in `a` if and only if `bc` == 0.
And `or` updates the Z flag!
So, after line {{#line_no_of "^\s*or a, c" ../assets/hello-world.asm:memcpy}}, the Z flag is set if and only if `bc` == 0, that is, if we should exit the loop.

And this is where conditional jumps come into the picture!
See, it's possible to **conditionally** "take" a jump depending on the state of the flags.

There are four "conditions":

Name     | Mnemonic | Description
---------|----------|----------------------------------------------------
Zero     | `z`      | Z is set (last operation had a result of 0)
Non-zero | `nz`     | Z is not set (last operation had a non-zero result)
Carry    | `c`      | C is set (last operation overflowed)
No carry | `nc`     | C is not set (last operation did not overflow)

Thus, `jp nz, CopyTiles` can be read as "if the Z flag is not set, then jump to `CopyTiles`".
Since we're jumping *backwards*, we will repeat the instructions again: we have just created a **loop**!

Okay, we've been talking about the code a lot, and we have seen it run, but we haven't really seen *how* it runs.
Let's watch the magic unfold in slow-motion in the next lesson!

---

[^pc_updates]:
Not exactly; instructions may be several bytes long, and PC increments after reading each byte.
Notably, this means that when an instruction finishes executing, PC is pointing to the following instruction.
Still, it's pretty much "where the CPU is currently reading from", but it's better to keep it simple and avoid mentioning instruction encoding for now.
