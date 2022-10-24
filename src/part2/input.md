# Input

We have the building blocks of a game here, but we're still lacking player input.
A game that plays itself isn't very much fun, so let's fix that.

Reading from the Game Boy's buttons is surprisingly *hard*, and it's outside the scope of this tutorial.
We're going to provide an input routine for this project since all we really want is to focus on input.

Paste this code below your `Main` loop. This is another function, and like `Memcpy` can be executed from different places using the `call` opcode.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:input-routine}}
{{#include ../../unbricked/input/main.asm:input-routine}}
```

Now that we know how to use functions, lets call the `UpdateKeys` function in our main loop to read user input.
`UpdateKeys` sets `wCurKeys`, which we'll read from after calling it.
Because of this we only need to call `UpdateKeys` once per frame; calling it more than once is slow and causes input to be inconsistent.

We're going to use the `bit` opcode, which sets the zero flag (`z`) to the value of the bit.
We can use this along with the `PADB` constants in hardware.inc to read a particular key.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:copy-paddle}}
{{#include ../../unbricked/input/main.asm:copy-paddle}}
```

Now if you compile your project, you should be able to move the paddle left and right using the d-pad.
