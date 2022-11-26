# Functions

So far, we have only written a single "flow" of code, but we can already spot some snippets that look redundant.
Let's use **functions** to "factor out" code!

For example, in three places, we are copying chunks of memory around.
Let's write a function below the `jp Main`, and let's call it `Memcpy`, like [the similar C function](https://man7.org/linux/man-pages/man3/memcpy.3.html):

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/functions/main.asm:memcpy}}
{{#include ../../unbricked/functions/main.asm:memcpy}}
```

In languages like C, functions automatically return when they reach the end of their scope.
However, functions in assembly don't have a definitive "end"; you always need to manually place a `ret` instruction at the end of the function to return from it

Notice that the function has a comment explaining which registers it takes as input.
This is important so that you know how to interface with the function.
We'll see more of this later on.

There are three places in your initialization code where you can use the `Memcpy` functions.
Find each of these copy loops and replace them with a call to `Memcpy`.
Make sure to leave the registers as-is; these are the parameters to the function.

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

In the next chapter we'll write a second function to read player input.
