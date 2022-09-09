# Memory

::: tip:🎉

Congrats, you have just finished the hardest lessons of the tutorial!
Since you have the basics, from now on, we'll be looking at more and more concrete code.

:::

If we look at line {{#line_no_of "^\s*ld a, \[de\]" ../assets/hello-world.asm}}, we see `ld a, [de]`.
Given what we just learned, this copies a value into register `a`... but where from?
What do these brackets mean?
To answer that, we need to talk about *memory*.

## What's a memory?

The purpose of memory is to store information.
On a piece of paper or a whiteboard, you can write letters to store the grocery list, for example.
But what can you store in a computer memory?
The answer to that question is *current*[^memory_magnetic].
Computer memory is made of little cells that can store current.
But, as we saw in the lesson about binary, the presence or absence of current can be used to encode binary numbers!

tl;dr: memory **stores numbers**.
In fact, memory is a *long* array of numbers, stored in cells.
To uniquely identify each cell, it's given a number (what else!) called its *address*.
Like street numbers!
The first cell has address 0, then address 1, 2, and so on.
On the Game Boy, each cell contains *8 bits*, i.e. a *byte*.

How many cells are there?
Well, this is actually a trick question...

## The many types of memory

There are several memory chips in the Game Boy, but we can put them into two categories: <abbr title="Read-Only Memory">ROM</abbr> and <abbr title="Random Access Memory">RAM</abbr>[^rom_ram_and].
ROM simply designates memory that cannot be written to[^rom_ro], and RAM memory that can be written to.

Due to how they work, the CPU, as well as the memory chips, can only use a single number for addresses.
Let's go back to the "street numbers" analogy: each memory chip is a street, with its own set of numbers, but the CPU has no idea what a street is, it only deals with street numbers.
To allow the CPU to talk to multiple chips, a sort of "postal service", the *chip selector*, is tasked with translating the CPU's street numbers into a street & street number.

For example, let's say a convention is established where addresses 0 through 1999 go to chip A's addresses 0&ndash;1999, 2000&ndash;2999 to chip B's 0&ndash;999, and 3000&ndash;3999 to chip C's 0&ndash;999.
Then, if the CPU asks for the byte at address 2791, the chip selector will ask chip B for the byte at its *own* address 791, and forward the reply to the CPU.

Since addresses dealt with by the CPU do not directly correspond to the chips' addresses, we talk about *logical* addresses (here, the CPU's) versus *physical* addresses (here, the chips'), and the correspondence is called a *memory map*.
Since we are programming the CPU, we will only be dealing with **logical** addresses, but it's crucial to keep in mind that different addresses may be backed by different memory chips, since each chip has unique characteristics.

This may sound complicated, so here is a summary:
- Memory stores numbers, each 8-bit on the Game Boy.
- Memory is accessed byte by byte, and the cell being accessed is determined by an *address*, which is just a number.
- The CPU deals with all memory uniformly, but there are several memory chips each with their own characteristics.

### Game Boy memory map

Let's answer the question that introduced this section: how many memory cells are there on the Game Boy?
Well, now, we can reframe this question as "how many logical addresses are there?" or "how many physical addresses are there in total?".

Logical addresses, which again are just numbers, are 16-bit on the Game Boy.
Therefore, there are 2^16 = 65536 logical addresses, from $0000 to $FFFF.
How many physical addresses, though?
Well, here is a memory map [courtesy of Pan Docs](https://gbdev.io/pandocs/Memory_Map.html) (though I will simplify it a bit):

Start | End   | Name | Description
------|-------|------|-------------------------------------------------------------------------
$0000 | $7FFF | ROM  | The game ROM, supplied by the cartridge.
$8000 | $9FFF | VRAM | Video RAM, where graphics are stored and arranged.
$A000 | $BFFF | SRAM | Save RAM, optionally supplied by the cartridge to save data to.
$C000 | $DFFF | WRAM | Work RAM, general-purpose RAM for the game to store things in.
$FE00 | $FE9F | OAM  | Object Attribute Memory, where "objects" are stored.
$FF00 | $FF7F | I/O  | Neither ROM nor RAM, but this is where you control the console.
$FF80 | $FFFE | HRAM | High RAM, a tiny bit of general-purpose RAM which can be accessed faster.
$FFFF | $FFFF | IE | A lone I/O byte that's separated from the rest for some reason.

$8000 + $2000 + $2000 + $2000 + $A0 + $80 + $7F + 1 adds up to $E1A0, or 57760 bytes of memory that can be *actually* accessed.
The curious reader will naturally ask, "What about the remaining 7776 bytes? What happens when accessing them?"; the answer is: "It depends, it's complicated; avoid accessing them".

## Labels

Okay, memory addresses are nice, but you can't possibly expect me to keep track of all these addresses manually, right??
Well, fear not, for we have labels!

Labels are [symbols](https://rgbds.gbdev.io/docs/v0.5.1/rgbasm.5#SYMBOLS) which basically allow attaching a name to a byte of memory.
A label is declared like at line {{#line_no_of "^\s*EntryPoint:" ../assets/hello-world.asm}} (`EntryPoint:`): at the beginning of the line, write the label's name, followed by a colon, and it will refer to the byte right after itself.
So, for example, `EntryPoint` refers to the `ld a, 0` right below it (more accurately, the first byte of that instruction, but we will get there when we get there).

::: tip

If you peek inside `hardware.inc`, you will see that for example `rNR52` is not defined as a label.
That's because they are *constants*, which we will touch on later; since they can be used mostly like labels, we will conflate the two for now.

:::

Writing out a label's name is equivalent to writing the address of the byte it's referencing (with a few exceptions we will see in Part Ⅱ).
For example, consider the `ld de, Tiles` at line {{#line_no_of "ld\s+de\s*,\s*Tiles" ../assets/hello-world.asm}}.
`Tiles` (line {{#line_no_of "^\s*Tiles:" ../assets/hello-world.asm}}) is referring to the first byte of the tile data; if we assume that the tile data ends up being stored starting at $0193, then `ld de, Tiles` is equivalent to `ld de, $0193`!

## What's with the brackets?

Right, we came into this because we wanted to know what the brackets in `ld a, [de]` mean.
Well, they can basically be read as "at address...".
For example, `ld a, b` can be read as "copy into `a` the value stored in `b`"; `ld a, [$5414]` would be read as "copy into `a` the value stored at address $5414", and `ld a, [de]` would be read as "copy into `a` the value stored at address `de`".
Wait, what does that mean?
Well, if `de` contains the value $5414, then `ld a, [de]` will do the same thing as `ld a, [$5414]`.

::: tip

If you're familiar with C, these brackets are basically how the dereference operator is implemented.

:::

### `hli`

An astute reader will have noticed the `ld [hli], a` just below the `ld a, [de]` we have just studied.
`[de]` makes sense because it's one of the register pairs we saw a couple lessons ago, but `[hli]`?
It's actually a special notation, which can also be written as `[hl+]`.
It functions as `[hl]`, but `hl` is *incremented* just after memory is accessed.
`[hld]`/`[hl-]` is the mirror of this one, *decrementing* `hl` instead of incrementing it.

## An example

So, if we look at the first two instructions of `CopyTiles`:

```rgbasm,linenos,start={{#line_no_of "" ../assets/hello-world.asm:memcpy_first_two}}
{{#include ../assets/hello-world.asm:memcpy_first_two}}
```

...we can see that we're copying the byte in memory *pointed to* by `de` (that is, whose address is contained in `de`) into the byte pointed to by `hl`.
Here, `a` serves as temporary storage, since the CPU is unable to perform `ld [hl], [de]` directly.

While we're at this, let's examine the rest of `.copyTiles` in the following lessons!

---

[^memory_magnetic]:
Actually, this depends a lot on the type of memory.
A lot of memory nowadays uses magnetic storage, but to keep the explanation simple, and to parallel the explanation of binary given earlier, let's assume that current is being used.

[^rom_ram_and]:
There are other types of memory, such as flash memory or EEPROM, but only Flash has been used on the Game Boy, and for only a handful of games; so we can mostly forget about them.

[^rom_ro]:
No, really!
Mask ROM is created by literally punching holes into a layer of silicon using acid, and e.g. the console's boot ROM is made of hard-wired transitors within the CPU die.
Good luck writing to that!
<br>
"ROM" is sometimes (mis)used to refer to "persistent memory" chips, such as flash memory, whose write functionality was disabled.
Most bootleg / "repro" Game Boy cartridges you can find nowadays actually contain flash; this is why you can reflash them using specialized hardware, but original cartridges cannot be.
