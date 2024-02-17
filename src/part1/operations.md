# Operations & flags

Alright, we know how to pass values around, but just copying numbers is no fun; we want to modify them!

The GB CPU does not provide every operation under the sun (for example, there is no multiplication instruction), but we can just program those ourselves with what we have.
Let's talk about some of the operations that it *does* have; I will be omitting some not used in the Hello World for now.

## Arithmetic

The simplest arithmetic instructions the CPU supports are `inc` and `dec`, which INCrement and DECrement their operand, respectively.
(If you aren't sure, "to increment" means "to add 1", and "to decrement" means "to subtract 1".)
So for example, the `dec bc` at line {{#line_no_of "^\s*dec bc" ../assets/hello-world.asm}} of `hello-world.asm` simply subtracts 1 from `bc`.

Okay, cool!
Can we go a bit faster, though?
Sure we can, with `add` and `sub`!
These respectively ADD and SUBtract arbitrary values (either a constant, or a register).
Neither is used in the tutorial, but a sibling of `sub`'s is: have you noticed little `cp` over at line {{#line_no_of "^\s*cp\b" ../assets/hello-world.asm}}?
`cp` allows ComParing values.
It works the same as `sub`, but it discards the result instead of writing it back.
"Wait, so it does nothing?" you may ask; well, it *does* update the **flags**.

## Flags

The time has come to talk about the special-purpose register (remember those?) `f`, for, well, *flags*.
The `f` register contains 4 bits, called "flags", which are updated depending on an operation's results.
These 4 flags are:

Name | Description
-----|---------------------
  Z  | Zero flag
  N  | Addition/subtraction
  H  | Half-carry
  C  | Carry

Yes, there is a flag called "C" and a register called "c", and **they are different, unrelated things**.
This makes the syntax a bit confusing at the beginning, but they are always used in different contexts, so it's fine.

We will forget about N and H for now; let's focus on Z and C.
Z is the simplest flag: it gets set when an operation's result is 0, and gets reset otherwise.
C is set when an operation *overflows* or *underflows*.

What's an overflow?
Let's take the simple instruction `add a, 42`.
This simply adds 42 to the contents of register `a`, and writes the result back into `a`.

```rgbasm
    ld a, 200
    add a, 42
```

At the end of this snippet, `a` equals 200 + 42 = 242, great!
But what if I write this instead?

```rgbasm
    ld a, 220
    add a, 42
```

Well, one could think that `a` would be equal to 220 + 42 = 262, but that would be incorrect.
Remember, `a` is an 8-bit register, *it can only store eight bits of information*!
And if we were to write 262 in binary, we would get %100000110, which requires at least 9 bits...
So what happens?
Simply, that ninth bit is *lost*, and the value that we end up with is %00000110 = 6.
This is called an *overflow*: after **adding**, we get a value **smaller** than what we started with.

We can also do the opposite with `sub`, and&mdash;for example&mdash;subtract 42 from 6; as we know, for all `X` and `Y`, `X + Y - Y = X`, and we just saw that 220 + 42 = 6 (this is called *modulo 256 arithmetic*, by the way); so, 6 - 42 = (220 + 42) - 42 = 220.
This is called an *underflow*: after **subtracting**, we get a value **greater** than what we started with.

When an operation is performed, it sets the carry flag if an overflow or underflow occurred, and clears it otherwise.
(We will see later that not all operations update the carry flag, though.)

:::tip Summary

- We can add and subtract numbers.
- The Z flag lets us know if the result was 0.
- However, registers can only store a limited range of integers.
- Going outside this range is called an **overflow** or **underflow**, for addition and subtraction respectively.
- The C flag lets us know if either occurred.

:::

## Comparison

Now, let's talk more about how `cp` is used to compare numbers.
Here is a refresher: `cp` subtracts its operand from `a` and updates flags accordingly, but doesn't write the result back.
We can use flags to check properties about the values being compared, and we will see in the next lesson how to use the flags.

The simplest interaction is with the Z flag.
If it's set, we know that the subtraction yielded 0, i.e. `a - operand == 0`; therefore, `a == operand`!
If it's not set, well, then we know that `a != operand`.

Okay, checking for equality is nice, but we may also want to perform *comparisons*.
Fret not, for the carry flag is here to do just that!
See, when performing a subtraction, the carry flag gets set when the result goes below 0—but that's just a fancy way of saying "becomes negative"!

So, when the carry flag gets set, we know that `a - operand < 0`, therefore that `a < operand`..!
And, conversely, we know that if it's *not* set, `a >= operand`.
Great!

## Instruction summary

Instruction | Mnemonic | Effect
------------|----------|---------------------------------------------
Add         | `add`    | Adds values to `a`
Subtract    | `sub`    | Subtracts values from `a`
Compare     | `cp`     | Compares values with what's contained in `a`
