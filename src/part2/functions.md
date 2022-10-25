# Functions

Earlier in this tutorial you copied various graphics from ROM into VRAM.
This operation is conventionally known as `Memcpy`, and by making it a function we can reuse the code in many places.
Write this below the `UpdateKeys` function:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:memcpy}}
{{#include ../../unbricked/functions/main.asm:memcpy}}
```

In languages like C, functions automatically return when they reach the end of their scope.
However, functions in assembly don't have a definative "end"; you always need to manually place a `ret` instruction at the end of the function to return from it.
The mechanics behind `call` and `ret` can be a bit complicated, so we'll explain how they work later.

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
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:copy-tiles}}
{{#include ../../unbricked/functions/main.asm:copy-tiles}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:copy-map}}
{{#include ../../unbricked/getting-started/main.asm:copy-tiles}}
```
becomes
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:copy-map}}
{{#include ../../unbricked/functions/main.asm:copy-map}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/objects/main.asm:copy-paddle}}
{{#include ../../unbricked/objects/main.asm:copy-paddle}}
```
becomes
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:copy-paddle}}
{{#include ../../unbricked/functions/main.asm:copy-paddle}}
```

In the next chapter we'll write a second function to read player input.
