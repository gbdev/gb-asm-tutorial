# Title Screen

The title screen shows a basic title image using the background and draws text for the user to press A. Once the user presses A, it will go to the story screen.

![Untitled](../assets/part3/img/title-screen-large.png)

Our title screen has 3 pieces of data:

* The "Press a to play" text
* The title screen tile data
* The title screen tilemap

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:title-screen-start}}
{{#include ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:title-screen-start}}
```

## Initiating the Title Screen

In our title screens "InitTitleScreen" function, we'll do the following:
* draw the title screen graphic
* draw our "press a to play"
* turn on the LCD. 


Here is what our "InitTitleScreenState" function looks like

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:title-screen-init}}
{{#include ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:title-screen-init}}
```

The "DrawTextTilesLoop" function comes from our "src/main/utils/text-utils.asm" class. It draws the text specified in hl, to the background/window address specified in de.  With that function created. Drawing the ‘press a to play’ at the background tilemap tile $99C3, is an easy task. We just need to call the function. Passing the starting address as de, and addresss to the actual text in hl. 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/text-utils.asm:draw-text-tiles}}
{{#include ../../galactic-armada/src/main/utils/text-utils.asm:draw-text-tiles}}
```

The "DrawTitleScreen" function puts the tiles for our title screen graphic in VRAM, and draws its tilemap to the background:

> **NOTE:** Because of the text font, we'll add an offset of 52 to our tilemap tiles. We've created a function that adds the 52 offset, since we'll need to do so more than once.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:draw-title-screen}}
{{#include ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:draw-title-screen}}
```

The "CopyDEintoMemoryAtHL" and "CopyDEintoMemoryAtHL_With52Offset" functions are defined in "src/main/utils/memory-utils.asm":

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/memory-utils.asm:memory-utils}}
{{#include ../../galactic-armada/src/main/utils/memory-utils.asm:memory-utils}}
```

## Updating the Title Screen

The title screen's update logic is the simplest of the 3. All we are going to do is wait until the A button is pressed. Afterwards, we'll go to the story screen game state.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:update-title-screen}}
{{#include ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:update-title-screen}}
```

Our "WaitForKeyFunction" is is defined in "src/main/utils/input-utils.asm". We'll poll for input and infinitely loop until the speicified button is pressed down.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/input-utils.asm:input-utils}}
{{#include ../../galactic-armada/src/main/utils/input-utils.asm:input-utils}}
```

That's it for our title screen. Next up is our story screen.