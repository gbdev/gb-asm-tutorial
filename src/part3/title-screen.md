# Title Screen

The title screen shows a basic title image using the background and draws text asking the player to press A. Once the user presses A, it will go to the story screen.

<img src="../assets/part3/img/title-screen-large.png" class="pixelated">

Our title screen has 3 pieces of data:

* The "Press A to play" text
* The title screen tile data
* The title screen tilemap

**Create a new assembly file called "title-screen-state.asm". You can put it anywhere, but we've organized ours in the "src/main/states/title-screen" folder.**

In that file, create ROM0 section, and add includes for "hardware.inc", and "character-mapping.inc"

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:title-screen-start}}
{{#include ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:title-screen-start}}
```

Like with pretty much every other file, we'll need the hardware.inc because of all it's useful helper constants. The character-mapping.inc comes with the starter. It's needed so RGBDS knows how to map our text to bytes.

Next, We're going to add 2 more functions to this file:
- InitTitleScreenState
- UpdateTitleScreenState

## Initiating the Title Screen

In our title screen's "InitTitleScreen" function, we'll do the following:
* Clear the background and any sprites (because other game states may change/use them)
* Reset the position of the background (because gameplay later will move it)
* draw the title screen graphic
* draw our "Press A to play"

However, like in the [second tutorial](https://gbdev.io/gb-asm-tutorial/part2/getting-started.html), before we cance change our background we need to turn off the LCD.

> "[We] wait until “VBlank”, which is the only time you can safely turn off the screen (doing so at the wrong time could damage a real Game Boy, so this is very crucial). We’ll explain what VBlank is and talk about it more later in the tutorial.
> 
> Turning off the screen is important because loading new tiles while the screen is on is tricky"
> *From Tutorial 2 - Regarding setting tile data and the LCD*

For drawing our title screen, because thats already been covered in previous tutorials, we've separated it and other assets into files already done in the starter. You can find the `DrawTitleScreen` function already done for you.

*In the "src/main/assets/backgrounds.asm (Already done in the starter)"*

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/assets/backgrounds.asm:draw-title-screen}}
{{#include ../../galactic-armada/src/main/assets/backgrounds.asm:draw-title-screen}}

;... other background assets
```

The same has been done (in the same file) for our text font. You can find in the "src/main/assets/backgrounds.asm", a `LoadTextFontIntoVRAM` function that populates VRAM with the tiles needed for text.

With those 2 functions done, Here is what our "InitTitleScreenState" function looks like

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:title-screen-init}}
{{#include ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:title-screen-init}}
```

In order to draw text in our game, we've created a function called "DrawTextInHL_AtDE". We'll pass this function which tile to start on in `de`, and the address of our text in `hl`.

You can find this function in the ["src/main/utils/text-utils.asm"](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/src/main/utils/text-utils.asm) file: 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/text-utils.asm:draw-text-tiles}}
{{#include ../../galactic-armada/src/main/utils/text-utils.asm:draw-text-tiles}}
```

Next, we need to update our logic for our title screen.

## Updating the Title Screen

The title screen's update logic is the simplest of the 3. All we are going to do is wait until the A button is pressed. Afterwards, we'll go to the story screen game state.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:update-title-screen}}
{{#include ../../galactic-armada/src/main/states/title-screen/title-screen-state.asm:update-title-screen}}
```

Our "WaitForKeyFunction" is defined in [ "src/main/utils/input-utils.asm"](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/src/main/utils/input-utils.asm). We'll poll for input and infinitely loop until the specified button is pressed down.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/input-utils.asm:input-utils}}
{{#include ../../galactic-armada/src/main/utils/input-utils.asm:input-utils}}
```

That's it for our title screen. Next up is our story screen.
