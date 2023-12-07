# Drawing Text

On each game state in Galactic Armada, you'll see dynamically drawn text. The Game Boy doesn't support "fonts", in the traditional sense. To draw text, you first populate VRAM with tiles that have letters/numbers/puncation on them.  Secondly, you render those tiles in a sequence on the window or background tilemap. 

You can see those text tiles in the text font asset included in the starter:

![Text Font.png](../assets/part3/img/text-font.png)

>**Note:** A function is included with the starter called `LoadTextFontIntoVRAM`. This function loads the tiles for the text font into VRAM.
## Mapping Characters to bytes

Everything with Game Boy game development uses bytes. There's no concept of "characters", "letters", or "strings". RGBDS allows you to use string when defining data. 

```rgbasm
wScoreText::  db "score", 255
```

The compiler will convert these strings to their byte equivalents. To do this, we need a [character mapping](https://rgbds.gbdev.io/docs/v0.6.1/rgbasm.5#Character_maps). The starter comes with a basic character mapping:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/includes/character-mapping.inc}}
{{#include ../../galactic-armada/src/main/includes/character-mapping.inc}}
```

The above character mapping will convert (during the compile process) the previous `wScoreText` data to: "44, 28 ,40 ,43 , 30, 255". As per the character mapping:
- The `s` converts to 44
- The `c` converts to 28
- The `o` converts to 40
- The `r` converts to 43
- The `e` converts to 30

>**Note:** These values come from the text font. 's' is the 44th tile, 'c' is the 28th tile, and so on...

The final 255 byte will be used by our text drawing function: `DrawTextInHL_AtDE`. It will let that function know we've reached the end.
## Drawing Basic Text

Our `DrawTextInHL_AtDE` function from the starter will write to the address defined in "de" the value in "hl". Then increasing both address, and looping again. This is done until we reach the "end-of-string" byte (255). You can find this function in the ["src/main/utils/text-utils.asm"](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/src/main/utils/text-utils.asm) file: 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/text-utils.asm:draw-text-tiles}}
{{#include ../../galactic-armada/src/main/utils/text-utils.asm:draw-text-tiles}}
```

## Animating Text with a Typewriter effect

To achieve a typewriter effect, we just need to wait between drawing each letters. It's would be identical to `DrawTextInHL_AtDE`, in terms of concepts. The difference would be that this function would wait for 3 vblank phases to pass, before drawing the next letter.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/text-utils.asm:typewriter-effect}}
{{#include ../../galactic-armada/src/main/utils/text-utils.asm:typewriter-effect}}
```

The starer takes this to the next level by adding a function for writing multiline text. This is used during the story game state.

![Story Game State.png](../assets/part3/img/rgbds-story-state.gif)

## Animating Multiline Text with a typewriter effect

The starter extends on the previous function to define `MultilineTypewriteTextInHL_AtDE`. This function simply uses `TypewriteTextInHL_AtDE`, adding 64 bytes to "de" (Where the text is drawn), until 

When the `TypewriteTextInHL_AtDE` function reaches the end of string character, a 255 byte; it will


```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/text-utils.asm:multiline-typewriter-effect}}
{{#include ../../galactic-armada/src/main/utils/text-utils.asm:multiline-typewriter-effect}}
```

In a later part of this tutorial, we will use that function with this data:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-data}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-data}}
```

Calling that function like so:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page1}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page1}}
```
## Drawing Numbers

For drawing numbers, we've created a function called `DrawBDigitsHL_OnDE`. To call this function, we need to specifiy:
- how many digits we want to draw in the `b` register
- a pointer to the digits in `hl`
- the address on the window/background where we want to draw them in `de`

>**Note:** The numbers in our text font start at tile 10. So, for each number read, we'll add 10 to it. 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/hud.asm:hud-draw-lives}}
{{#include ../../galactic-armada/src/main/states/gameplay/hud.asm:hud-draw-lives}}
```

We will later call that function like so:

>**Note:** In this example, our `wScore` variable has 6 bytes. Each byte represents one digit.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:draw-score}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:draw-score}}
```