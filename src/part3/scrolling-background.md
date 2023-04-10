
# Scrolling Background

Scrolling the background is an easy task. However, for a SMOOTH slow scrolling background: scaled integers will be used.

>⚠️ Scaled Integers are a way to provide smooth “sub-pixel” movement. They are slightly more difficult to understand & implement than implementing a counter, but they provide smoother motion.

To scroll the background in a gameboy game, we simply need to gradually change the `SCX` or `SCX` registers. Our code is a tiny bit more complicated because of scaled integer usage. Our background's scroll position is stored in a 16-bit integer called `mBackgroundScroll`. We'l increase that 16-bit integer by a set amount. The value we draw our background at will be the non-scaled version of that 16-bit integer. To get that non-scaled version, we'll simply shift all of it's bit rightward 4 places. The final result will saved for when we update our background's y position.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:scrolling-background}}
{{#include ../../galactic-armada/main.asm:scrolling-background}}
```