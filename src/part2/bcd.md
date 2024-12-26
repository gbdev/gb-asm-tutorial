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

Now we'll write a function to increase the score, right behind the `IsWallTile` function.
Don't worry about the call to `UpdateScoreBoard`, we'll get into that in a bit.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/bcd/main.asm:increase-score}}
{{#include ../../unbricked/bcd/main.asm:increase-score}}
```

Let's have a look at what's going on there:
We set A to 1 and clear the carry flag
We add the score variable (contents of memory location `wScore`) to a, so now A has our increased score.

So far so good, but what if the score was 9 and we add 1? The processor thinks in binary only and will do the following math:

`%00001001` + `%00000001` = `%00001010` = `$A`

That's a hexadecimal representation of 10, and we need to adjust it to become decimal. `DAA` or "Decimal Adjust after Addition," does just that.
After executing `DAA` our accumulator will be adjusted from `%00001010` to `%00010000`; a 1 in the left nibble and a 0 in the right one. A more detailed article about `DAA` on the Game Boy can be found [here](https://blog.ollien.com/posts/gb-daa/).

Then we store the score back into `wScore` and finally, we call a function that will update the score board, which we will implement next.