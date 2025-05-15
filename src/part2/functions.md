# Functions

{{#use_commit ../../unbricked@"Lesson 3: Functions"}}

So far, we have only written a single "flow" of code, but we can already spot some snippets that look redundant.
Let's use **functions** to "factor out" code!

For example, in three places, we are copying chunks of memory around.
Let's write a function below the `jp Main`, and let's call it `Memcpy`, like [the similar C function](https://man7.org/linux/man-pages/man3/memcpy.3.html):

```rgbasm,linenos,start={{#line_no_of "" @GIT@/main.asm:memcpy}}
{{#include_git main.asm:memcpy}}
```

The new `ret` instruction should immediately catch our eye.
It is, unsurprisingly, what makes execution _return_ to where the function was _called_ from.
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

{{#use_commit ../../unbricked@"Lesson 1: Getting Started"}}

```rgbasm,linenos,start={{#line_no_of "" @GIT@/main.asm:copy_tiles}}
{{#include_git main.asm:copy_tiles}}
```

</td><td>

{{#use_commit ../../unbricked@"Lesson 3: Functions"}}

```rgbasm,linenos,start={{#line_no_of "" @GIT@/main.asm:copy_tiles}}
{{#include_git main.asm:copy_tiles}}
```

</td></tr><tr><td>

{{#use_commit ../../unbricked@"Lesson 1: Getting Started"}}

```rgbasm,linenos,start={{#line_no_of "" @GIT@/main.asm:copy_map}}
{{#include_git main.asm:copy_map}}
```

</td><td>

{{#use_commit ../../unbricked@"Lesson 3: Functions"}}

```rgbasm,linenos,start={{#line_no_of "" @GIT@/main.asm:copy_map}}
{{#include_git main.asm:copy_map}}
```

</td></tr><tr><td>

{{#use_commit ../../unbricked@"Lesson 2: Objects"}}

```rgbasm,linenos,start={{#line_no_of "" @GIT@/main.asm:copy-paddle}}
{{#include_git main.asm:copy-paddle}}
```

</td><td>

{{#use_commit ../../unbricked@"Lesson 3: Functions"}}

```rgbasm,linenos,start={{#line_no_of "" @GIT@/main.asm:copy_paddle}}
{{#include_git main.asm:copy_paddle}}
```

</td></tr></tbody></table></div>

In the next chapter, we'll write another function, this time to read player input.
