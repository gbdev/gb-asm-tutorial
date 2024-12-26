# Decimal Numbers

Now that we can make the bricks disappear on impact, we should probably get some reward, like points!
We'll start off with a score of 0 and then increase the score by 1 point each time a brick gets destroyed.
Then we can display the score on a scoreboard.

## BCD

As we're stingy when it comes to memory use, we will only use one byte. There are different ways of saving and retrieving numbers as decimals, but this time we will choose something called "Packed Binary Coded Decimal" or packed BCD for short.

BCD is a way of storing decimal numbers in bytes, not using A-F, so $A would be 10 which consists of the digits 1 and 0.

Remember how bits, nibbles and bytes work? Go and have a look at the [Hexadeciamal](../part1/bin_and_hex.md) section if you need a reminder.

The "packed" part means that we pack 2 digits into one byte. A byte contains 8 bits and inside 4 bits we can already store numbers between `$0` (`%0000`) and `$F` (`%1111`), which is more than sufficent to store a number between 0 and 9.

For example the number 35 (my favorite Pokémon) contains the number 3 `%0011` and 5 `%0101` and as a packed BCD this is `%00110101`

## Calculating the score

Now let's start by defining a global variable (memory location) for the score:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/bcd/main.asm:score-variable}}
{{#include ../../unbricked/bcd/main.asm:score-variable}}
```

And we'll set this to zero when initializing the other global variables.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/bcd/main.asm:init-variables}}
{{#include ../../unbricked/bcd/main.asm:init-variables}}
```
