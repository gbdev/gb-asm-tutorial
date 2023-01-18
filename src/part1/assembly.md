# Assembly basics

Alright, now that we know what the tools *do*, let's see what language RGBASM speaks.
I will take a short slice of the beginning of `hello-world.asm`, so that we agree on the line numbers, and you can get some syntax highlighting even if your editor doesn't support it.

```rgbasm,linenos,start={{#line_no_of "" ../assets/hello-world.asm:basics}}
{{#include ../assets/hello-world.asm:basics}}
```

Let's analyze it.
Note that I will be ignoring a *lot* of RGBASM's functionality; if you're curious to know more, you should wait until parts II and III, or [read the docs](https://rgbds.gbdev.io/docs).

## Comments

We'll start with line {{#line_no_of "^\s*;" ../assets/hello-world.asm:basics}}, which should appear gray above.
Semicolons `;` denote *comments*.
Everything from a semicolon to the end of the line is *ignored* by RGBASM.
As you can see on line {{#line_no_of "^.*\s.*;" ../assets/hello-world.asm:basics}}, comments need not be on an otherwise empty line.

Comments are a staple of every good programming language; they are useful to give context as to what code is doing.
They're the difference between "Pre-heat the oven at 180 °C" and "Pre-heat the oven at 180 °C, any higher and the cake would burn", basically.
In any language, good comments are very useful; in assembly, they play an even more important role, as many common semantic facilities are not available.

## Instructions

Assembly is a very line-based language.
Each line can contain one of two things:
- a *directive*, which instructs RGBASM to do something, or
- an *instruction*[^instr_directive], which is written directly into the ROM.

We will talk about directives later, for now let's focus on instructions: for example, in the snippet above, we will ignore lines {{#line_no_of "^\s*INCLUDE" ../assets/hello-world.asm:basics}} (`INCLUDE`), {{#line_no_of "^\s*ds" ../assets/hello-world.asm:basics}} (`ds`), and {{#line_no_of "^\s*SECTION" ../assets/hello-world.asm:basics}} (`SECTION`).

To continue the cake-baking analogy even further, instructions are like steps in a recipe.
The console's processor (<abbr title="Central Processing Unit">CPU</abbr>) executes instructions one at a time, and that... eventually does something!
Like baking a cake, drawing a "Hello World" image, or displaying a Game Boy programming tutorial!
\*wink\* \*wink\*

Instructions have a *mnemonic*, which is a name they are given, and *operands*, which indicate what they should act upon.
For example, in "melt the chocolate and butter in a saucepan", *the whole sentence* would be the instruction, *the verb* "melt" would be the mnemonic, and "chocolate", "butter", and "saucepan" the operands, i.e. some kind of parameters to the operation.

Let's discuss the most fundamental instruction, **`ld`**.
`ld` stands for "LoaD", and its purpose is simply to copy data from its right operand (["<abbr title="Right-Hand Side">RHS</abbr>"](https://en.wikipedia.org/wiki/Sides_of_an_equation)) into its left operand (["<abbr title="Left-Hand Side">LHS</abbr>"](https://en.wikipedia.org/wiki/Sides_of_an_equation)).
For example, take line {{#line_no_of "^\s*ld a, 0" ../assets/hello-world.asm:basics}}'s `ld a, 0`: it copies ("loads") the value 0 into the 8-bit register `a`[^ld_imm_from].
If you look further in the file, line {{#line_no_of "^\s*ld a, b" ../assets/hello-world.asm}} has `ld a, b`, which causes the value in register `b` to be copied into register `a`.

Instruction | Mnemonic | Effect
------------|----------|----------------------
Load        | `ld`     | Copies values around

::: tip:ℹ️

Due to CPU limitations, not all operand combinations are valid for `ld` and many other instructions; we will talk about this when writing our own code later.

:::

::: tip:🤔

RGBDS has an [instruction reference](https://rgbds.gbdev.io/docs/gbz80.7) worth bookmarking, and you can also consult it locally with `man 7 gbz80` if RGBDS is installed on your machine (except Windows...).
The descriptions there are more succinct, since they're intended as reminders, not as tutorials.

:::

## Directives

In a way, instructions are destined to the console's CPU, and comments are destined to the programmer.
But some lines are neither, and are instead sort of metadata destined to RGBDS itself.
Those are called *directives*, and our Hello World actually contains three of those.

### Including other files

```rgbasm,linenos
{{#include ../assets/hello-world.asm:4}}
```

Line 1 *includes* `hardware.inc`[^hw_inc_directives].
Including a file has the same effect as if you copy-pasted it, but without having to actually do that.

It allows sharing code across files easily: for example, if two files `a.asm` and `b.asm` were to include `hardware.inc`, you would only need to modify `hardware.inc` once for the modifications to apply to both `a.asm` and `b.asm`.
If you instead copy-pasted the contents manually, you would have to edit both copies in `a.asm` and `b.asm` to apply the changes, which is more tedious and error-prone.

`hardware.inc` defines a bunch of constants related to interfacing with the hardware.
Constants are basically names with a value attached, so when you write out their name, they are replaced with their value.
This is useful because, for example, it is easier to remember the address of the **LCD** **C**ontrol register as `rLCDC` than `$FF40`.

We will discuss constants in more detail in Part Ⅱ.

### Sections

Let's first explain what a "section" is, then we will see what line 3 does.

A section represents a contiguous range of memory, and by default, ends up *somewhere* not known in advance.
If you want to see where all the sections end up, you can ask RGBLINK to generate a "map file" with the `-m` flag:

```console
$ rgblink hello-world.o -m hello-world.map
```

...and we can see, for example, where the `"Tilemap"` section ended up:

```
  SECTION: $05a6-$07e5 ($0240 bytes) ["Tilemap"]
```

Sections cannot be split by RGBDS, which is useful e.g. for code, since the processor executes instructions one right after the other (except jumps, as we will see later).
There is a balance to be struck between too many and not enough sections, but it typically doesn't matter much until banking is introduced into the picture—and it won't be until much, much later.

So, for now, let's just assume that one section should contain things that "go together" topically, and let's examine one of ours.

```rgbasm,linenos,start=3
{{#include ../assets/hello-world.asm:6}}
```

So!
What's happening here?
Well, we are simply declaring a new section; all instructions and data after this line and until the next `SECTION` one will be placed in this newly-created section.
Before the first `SECTION` directive, there is no "active" section, and thus generating code or data will be met with a `Cannot output data outside of a SECTION` error.

The new section's name is "`Header`".
Section names can contain any characters (and even be empty, if you want), and must be unique[^sect_name].
The `ROM0` keyword indicates which "memory type" the section belongs to ([here is a list](https://rgbds.gbdev.io/docs/v0.5.2/rgbasm.5#SECTIONS)).
We will discuss them in Part Ⅱ.

The `[$100]` part is more interesting, in that it is unique to this section.
See, I said above that:

> a section \[...\] by default, ends up *somewhere* not known in advance.

However, some memory locations are special, and so sometimes we need a specific section to span a specific range of memory.
To enable this, RGBASM provides the `[addr]` syntax, which *forces* the section's starting address to be `addr`.

In this case, the memory range $100–$14F is special, as it is the *ROM's header*.
We will discuss the header in a couple lessons, but for now, just know that we need not to put any of our code or data in that space.
How do we do that?
Well, first, we begin a section at address $100, and then we need to reserve some space.

### Reserving space

```rgbasm,linenos,start=5
{{#include ../assets/hello-world.asm:8:10}}
```

Line 7 claims to "Make room for the header", which I briefly mentioned just above.
For now, let's focus on what `ds` actually does.

`ds` is used for *statically* allocating memory.
It simply reserves some amount of bytes, which are set to a given value.
The first argument to `ds`, here `$150 - @`, is *how many bytes to reserve*.
The second (optional) argument, here `0`, is *what value to set each reserved byte to*[^ds_pattern].

We will see why these bytes must be reserved in a couple of lessons.

It is worth mentioning that this first argument here is an *expression*.
RGBDS (thankfully!) supports arbitrary expressions essentially anywhere.
This expression is a simple subtraction: $150 minus `@`, which is a special symbol that stands for "the current memory address".

::: tip

A symbol is essentially "a name attached to a value", usually a number.
We will explore the different types of symbols throughout the tutorial, starting with labels in the next section.

A numerical symbol used in an expression evaluates to its value, which must be known when compiling the ROM—in particular, it can't depend on any register's contents.

:::

Oh, but you may be wondering what the "memory addresses" I keep mentioning are.
Let's see about those!

---

[^instr_directive]:
Technically, instructions in RGBASM are implemented as directives, basically writing their encoded form to the ROM; but the distinction between the instructions in the source code and those in the final ROM is not worth bringing up right now.

[^ld_imm_from]:
The curious reader may ask where the value is copied *from*. The answer is simply that the \"immediate\" byte ($00 in this example) is stored in ROM just after the instruction's opcode byte, and it's what gets copied to `a`.
We will come back to this when we talk about how instructions are encoded later on.

[^hw_inc_directives]:
`hardware.inc` itself contains more directives, in particular to define a lot of symbols.
They will be touched upon much later, so we won't look into `hardware.inc` yet.

[^sect_name]:
Section names actually only need to be unique for "plain" sections, and function differently with "unionized" and "fragment" sections, which we will discuss much later.

[^ds_pattern]:
Actually, since RGBASM 0.5.0, `ds` can accept a *list* of bytes, and will repeat the pattern for as many bytes as specified.
It just complicates the explanation slightly, so I omitted it for now.
Also, if the argument is omitted, it defaults to what is specified using the `-p` option **to RGBASM**.
