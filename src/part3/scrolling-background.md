
# Scrolling Background

Scrolling the background is an easy task. However, for a SMOOTH slow scrolling background, scaled integers will be used.

<aside>
⚠️ Scaled Integers are a way to provide smooth “sub-pixel” movement. They are slightly more difficult to understand & implement than implementing a counter, but they provide smoother motion.

</aside>

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:scrolling-background}}
{{#include ../../galactic-armada/main.asm:scrolling-background}}
```