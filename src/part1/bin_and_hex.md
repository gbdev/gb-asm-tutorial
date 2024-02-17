# Binary and hexadecimal

Before we talk about the code, a bit of background knowledge is in order.
When programming at a low level, understanding of *[binary](https://en.wikipedia.org/wiki/Binary_number)* and *[hexadecimal](https://en.wikipedia.org/wiki/Hexadecimal)* is mandatory.
Since you may already know about both of these, a summary of the RGBDS-specific information is available at the end of this lesson.

So, what's binary?
It's a different way to represent numbers, in what's called *base 2*.
We're used to counting in [base 10](https://en.wikipedia.org/wiki/Decimal), so we have 10 digits: 0, 1, 2, 3, 4, 5, 6, 7, 8, and 9.
Here's how digits work:

```
  42 =                       4 × 10   + 2
     =                       4 × 10^1 + 2 × 10^0
                                  ↑          ↑
    These tens come from us counting in base 10!

1024 = 1 × 1000 + 0 × 100  + 2 × 10   + 4
     = 1 × 10^3 + 0 × 10^2 + 2 × 10^1 + 4 × 10^0
       ↑          ↑          ↑          ↑
And here we can see the digits that make up the number!
```

:::tip:ℹ️

`^` here means "to the power of", where `X^N` is equal to multiplying `X` with itself `N` times, and `X ^ 0 = 1`.

:::

Decimal digits form a unique *decomposition* of numbers in powers of 10 (*deci*mal is base 10, remember?).
But why stop at powers of 10?
We could use other bases instead, such as base 2.
(Why base 2 specifically will be explained later.)

Binary is base 2, so there are only two digits, called *bits*: 0 and 1.
Thus, we can generalize the principle outlined above, and write these two numbers in a similar way:

```
  42 =                                                    1 × 32  + 0 × 16  + 1 × 8   + 0 × 4   + 1 × 2   + 0
     =                                                    1 × 2^5 + 0 × 2^4 + 1 × 2^3 + 0 × 2^2 + 1 × 2^1 + 0 × 2^0
                                                              ↑         ↑         ↑         ↑         ↑         ↑
                                          And since now we're counting in base 2, we're seeing twos instead of tens!

1024 = 1 × 1024 + 0 × 512 + 0 × 256 + 0 × 128 + 0 × 64  + 0 × 32  + 0 × 16  + 0 × 8   + 0 × 4   + 0 × 2   + 0
     = 1 × 2^10 + 0 × 2^9 + 0 × 2^8 + 0 × 2^7 + 0 × 2^6 + 0 × 2^5 + 0 × 2^4 + 0 × 2^3 + 0 × 2^2 + 0 × 2^1 + 0 × 2^0
       ↑          ↑         ↑         ↑         ↑         ↑         ↑         ↑         ↑         ↑         ↑
```

So, by applying the same principle, we can say that in base 2, 42 is written as `101010`, and 1024 as `10000000000`. 
Since you can't tell ten (decimal 10) and two (binary 10) apart, RGBDS assembly has binary numbers prefixed by a percent sign: 10 is ten, and %10 is two.

Okay, but why base 2 specifically?
Rather conveniently, a bit can only be 0 or 1, which are easy to represent as "ON" or "OFF", empty or full, etc!
If you want, at home, to create a one-bit memory, just take a box.
If it's empty, it stores a 0; if it contains *something*, it stores a 1.
Computers thus primarily manipulate binary numbers, and this has a *slew* of implications, as we will see throughout this entire tutorial.

## Hexadecimal

To recap, decimal isn't practical for a computer to work with, instead relying on binary (base 2) numbers.
Okay, but binary is really impractical to work with.
Take %10000000000, aka 2048; when in decimal only 4 digits are required, binary instead needs 12!
And, did you notice that I actually wrote one zero too few?
Fortunately, hexadecimal is here to save the day! 🦸

Base 16 works just the same as every other base, but with 16 digits, called *nibbles*: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, and F.

```
  42 =            2 × 16   + 10
     =            2 × 16^1 + A × 16^0

1024 = 4 × 256  + 0 × 16   + 0
     = 4 × 16^2 + 0 × 16^1 + 0 × 16^0
```

Like binary, we will use a prefix to denote hexadecimal, namely `$`.
So, 42 = $2A, and 1024 = $400.
This is *much* more compact than binary, and slightly more than decimal, too; but what makes hexadecimal very interesting is that one nibble corresponds *exactly* to 4 bits!

 Nibble | Bits
:------:|:----:
     $0 | %0000
     $1 | %0001
     $2 | %0010
     $3 | %0011
     $4 | %0100
     $5 | %0101
     $6 | %0110
     $7 | %0111
     $8 | %1000
     $9 | %1001
     $A | %1010
     $B | %1011
     $C | %1100
     $D | %1101
     $E | %1110
     $F | %1111

This makes it very easy to convert between binary and hexadecimal, while retaining a compact enough notation.
Thus, hexadecimal is used a lot more than binary.
And, don't worry, decimal can still be used 😜

(Side note: one could point that octal, i.e. base 8, would also work for this; however, we will primarily deal with units of 8 bits, for which hexadecimal works much better than octal. RGBDS supports octal via the `&` prefix, but I have yet to see it used.)

:::tip:💡

If you're having trouble converting between decimal and binary/hexadecimal, check if your favorite calculator program doesn't have a "programmer" mode, or a way to convert between bases.

:::

## Summary

- In RGBDS assembly, the hexadecimal prefix is `$`, and the binary prefix is `%`.
- Hexadecimal can be used as a "compact binary" notation.
- Using binary or hexadecimal is useful when individual bits matter; otherwise, decimal works just as well.
- For when numbers get a bit too long, RGBASM allows underscores between digits (`123_465`, `%10_1010`, `$DE_AD_BE_EF`, etc.)
