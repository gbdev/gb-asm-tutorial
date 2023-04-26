# Story Screen

The story screens shows a basic generic story on 2 pages. The story text is shown using a typewriter effect. This effect is done the same way the “press a to play” text was done before. Except, for the typewriter effect. With this effect we are waiting 3 vertical blank phases between writing each letter. Which gives a small delay. You could bind this to a variable and make it configurable via an options screen too!

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:draw-text-typewriter}}
{{#include ../../galactic-armada/main.asm:draw-text-typewriter}}
```


That function is called from the story game state like so:


```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:story-state}}
{{#include ../../galactic-armada/main.asm:story-state}}
```

The final result.

![GalacticArmada-1.png](../assets/part3/img/GalacticArmada-1.png)

![GalacticArmada-2.png](../assets/part3/img/GalacticArmada-2.png)

In terms of update logic, The story state simply wait’s for A to be pressed then goes to the next screen/state. The “WaitForKeyFunction” function halts the entire program until the given key is just pressed. Which key to wait for, passed in the RAM variable mWaitKey

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:wait-for-key}}
{{#include ../../galactic-armada/main.asm:wait-for-key}}
```