# Functions

So far, we have only written a single "flow" of code, but we can already spot some snippets that look redundant.
Let's use **functions** to "factor out" code!

For example, in three places, we are copying chunks of memory around.
Let's write a function below the `jp Main`, and let's call it `Memcpy`, like [the similar C function](https://man7.org/linux/man-pages/man3/memcpy.3.html):

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:memcpy}}
{{#include ../../unbricked/functions/main.asm:memcpy}}
```

The new `ret` instruction should immediately catch our eye.
It is, unsurprisingly, what makes execution *return* to where the function was *called* from.
Importantly, many languages have a definite "end" to a function: in C or Rust, that's the closing brace `}`; in Pascal or Lua, the keyword `end`, and so on; the function implicitly returns when execution reaches its end.
However, **this is not the case in assembly**, so you must remember to add a `ret` instruction at the end of the function to return from it!
Otherwise, the results are unpredictable.

Notice the comment above the function, explaining which registers it takes as input.
This comment is important so that you know how to interface with the function; assembly has no formal parameters, so comments explaining them are even more important than with other languages.
We'll see more of those as we progress.

There are three places in the initialization code where we can use the `Memcpy` function.
Find each of these copy loops and replace them with a call to `Memcpy`; for this, we use the `call` instruction.
The registers serve as parameters to the function, so we'll leave them as-is.

<div class="table-wrapper"><table><thead><tr><th>Before</th><th>After</th></tr></thead><tbody><tr><td>

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:copy_tiles}}
{{#include ../../unbricked/getting-started/main.asm:copy_tiles}}
```

</td><td>

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:copy_tiles}}
{{#include ../../unbricked/functions/main.asm:copy_tiles}}
```

</td></tr><tr><td>

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/getting-started/main.asm:copy_map}}
{{#include ../../unbricked/getting-started/main.asm:copy_map}}
```

</td><td>

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:copy_map}}
{{#include ../../unbricked/functions/main.asm:copy_map}}
```

</td></tr><tr><td>

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/objects/main.asm:copy-paddle}}
{{#include ../../unbricked/objects/main.asm:copy-paddle}}
```

</td><td>

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:copy_paddle}}
{{#include ../../unbricked/functions/main.asm:copy_paddle}}
```

</td></tr></tbody></table></div>

In the next chapter, we'll write another function, this time to read player input.
