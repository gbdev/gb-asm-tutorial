# Input

We have the building blocks of a game here, but we're still lacking user input.
A game that plays itself isn't very much fun, so let's fix that.

Reading from the Game Boy's buttons is surprisingly *hard*, and it's outside the scope of this tutorial.
We're going to provide an input routine for this project since all we really want is to focus on input.

Paste this code below your `Main` loop. This is a *function*, that can be executed from different places using the `call` opcode.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:input-routine}}
{{#include ../../unbricked/input/main.asm:input-routine}}
```

Before we use this function, lets practice writing our own.
Earlier in this tutorial you copied various graphics from ROM into VRAM.
This operation is conventionally known as `Memcpy`, and by making it a function we can reuse the code in many places.
Write this below the `UpdateKeys` function:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:memcpy}}
{{#include ../../unbricked/input/main.asm:memcpy}}
```

Notice that the function has a comment explaining which registers it takes as input.
This is important so that you know how to interface with the function.
We'll see more of this later on.

There are three places in your initialization code where you can use the `Memcpy` functions.
Find each of these copy loops and replace them with a call to `Memcpy`.
Make sure to leave the registers as-is; these are the parameters to the function.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:copy-tiles}}
{{#include ../../unbricked/getting-started/main.asm:copy-tiles}}
```
becomes
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:copy-tiles}}
{{#include ../../unbricked/input/main.asm:copy-tiles}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:copy-map}}
{{#include ../../unbricked/getting-started/main.asm:copy-tiles}}
```
becomes
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:copy-map}}
{{#include ../../unbricked/input/main.asm:copy-map}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/objects/main.asm:copy-paddle}}
{{#include ../../unbricked/objects/main.asm:copy-paddle}}
```
becomes
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:copy-paddle}}
{{#include ../../unbricked/input/main.asm:copy-paddle}}
```

Now that we know how to use functions, lets call the `UpdateKeys` function in our main loop to read user input.
`UpdateKeys` sets `wCurKeys` which we'll read from after calling it.
Because of this we only need to call `UpdateKeys` once per frame; calling it more than once is slow and causes input to be inconsistent.

We're going to use the `bit` opcode, which sets the zero flag (`z`) to the value of the bit.
We can use this along with the `PADB` constants in hardware.inc to read a particular key.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/input/main.asm:copy-paddle}}
{{#include ../../unbricked/input/main.asm:copy-paddle}}
```

Now if you compile your project, you should be able to move the paddle left and right using the d-pad.
