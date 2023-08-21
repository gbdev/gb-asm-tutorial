
# Scrolling Background

Scrolling the background is an easy task. However, for a SMOOTH slow scrolling background: scaled integers[^1] will be used.

>⚠️ Scaled Integers[^1] are a way to provide smooth “sub-pixel” movement. They are slightly more difficult to understand & implement than implementing a counter, but they provide smoother motion.

## Initializing the Background

At the start of the gameplay game state we called the initialize background function. This function shows the star field background, and resets our background scroll variables:

> Just like with our title screen graphic, because our text font tiles are at the beginning of VRAM: we offset the tilemap values by 52

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-background.asm:gameplay-background-initialize}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-background.asm:gameplay-background-initialize}}
```

To scroll the background in a gameboy game, we simply need to gradually change the `SCX` or `SCX` registers. Our code is a tiny bit more complicated because of scaled integer usage. Our background's scroll position is stored in a 16-bit integer called `mBackgroundScroll`. We'l increase that 16-bit integer by a set amount.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-background.asm:gameplay-background-update-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-background.asm:gameplay-background-update-start}}
``` 

We won't directly draw the background using this value. De-scaling a scaled integer simulates having a (more precise and useful for smooth movement) floating-point number. The value we draw our background at will be the de-scaled version of that 16-bit integer. To get that non-scaled version, we'll simply shift all of it's bit rightward 4 places. The final result will saved for when we update our background's y position.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-background.asm:gameplay-background-update-end}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-background.asm:gameplay-background-update-end}}
``` 

[^1]: [Scaled Factor on Wikipedia](https://en.wikipedia.org/wiki/Scale_factor_(computer_science))