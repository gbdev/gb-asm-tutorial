# Input

We have the building blocks of a game here, but we're still lacking player input.
A game that plays itself isn't very much fun, so let's fix that.

Paste this code below your `Main` loop.
Like `Memcpy`, this is a function that can be reused from different places, using the `call` instruction.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:input-routine}}
{{#include ../../unbricked/input/main.asm:input-routine}}
```

Now that we know how to use functions, let's call the `UpdateKeys` function in our main loop to read user input.
`UpdateKeys` writes the held buttons to a location in memory that we called `wCurKeys`, which we can read from after the function returns.
Because of this, we only need to call `UpdateKeys` once per frame.

This is good, because not only is it faster to just read the inputs last read, it also means that we will always act on the same inputs, even if the player presses or releases a button mid-frame.

We're going to use the `bit` opcode, which sets the zero flag (`z`) to the value of the bit.
We can use this along with the `PADB` constants in hardware.inc to read a particular key.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:copy_paddle}}
{{#include ../../unbricked/input/main.asm:copy_paddle}}
```

Now if you compile your project, you should be able to move the paddle left and right using the d-pad.
