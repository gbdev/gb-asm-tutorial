# Keeping Score and Drawing Score on the HUD

To keep things simple, we use 6 different bytes to hold our score.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:score-variables}}
{{#include ../../galactic-armada/main.asm:score-variables}}
```

Each byte will hold a value between 0 and 9, and represents a specific digit in the score. So it’s easy to loop through and edit the score number on the HUD: The First byte represents the left-most digit, and the last byte represents the right-most digit. 

When the score increases, we’ll increase digits on the right. As they go higher than 9, we’ll reset back to 0 and increase the previous byte .

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:increase-score}}
{{#include ../../galactic-armada/main.asm:increase-score}}
```

We can call that score whenever a bullet hits an enemy. This function however does not draw our score on the background. We do that the same way we drew text previously:


```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:draw-score}}
{{#include ../../galactic-armada/main.asm:draw-score}}
```
