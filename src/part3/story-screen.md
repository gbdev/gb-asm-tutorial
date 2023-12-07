# Story Screen

The story screen shows a basic story on 2 pages. Afterwards, it sends the player to the gameplay game state.

<img src="../assets/part3/img/GalacticArmada-1.png" class="pixelated" height="288px">

<img src="../assets/part3/img/GalacticArmada-2.png" class="pixelated" height="288px">

## Initiating up the Story Screen

In the `InitStoryState` we'll just going to turn on the LCD. Most of the game state's logic will occur in its update function.

**Create a file named `story-screen.asm`. In that file add includes to `hardware.inc` and `character-mapping.inc`, and create a section in ROM0.**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:header}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:header}}
```

Like we did with the title screen, we'll need to setup a function for the Story State's initation logic. This function, called `InitStoryState` will be very similar to that of the title screen. The major difference is that nothing will be drawn in the `InitStoryState` function.

**Add the following to your new `story-screen.asm` file.**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:init-story-state}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:init-story-state}}
```

## Updating the Story Screen

Here's the data for our story screen. We have this defined just above our `UpdateStoryState` function. 

**Copy this data into your `story-screen.asm` file.**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-data}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-data}}
```

The story text is shown using a typewriter effect. This effect is done similarly to the “press a to play” text that was done before, but here we wait for 3 vertical blank phases between writing each letter, giving some additional delay.

> **Note: The `WaitForAToBePressed` is a utility function that comes with the starter. You can find more info on it in the [utilties page](utilities.md). **

We'll call the `MultilineTypewriteTextInHL_AtDE` function exactly how we called the `DrawTextTilesLoop` function. 

**Create a function called `UpdateStoryState` in `story-state.asm`. Export this function and tell it to call the `MultilineTypewriteTextInHL_AtDE` function. Pass `$9821` t DE as the location to start writing/drawing. Pass `Story.Line1` to HL as the text draw.**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page1}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page1}}
```

Our basic story has 2 pages. After the first page has drawn, we'll wait until the A button is pressed. After such, we'll start drawing the second page. In-between pages we need to clear the background, so no extra text tiles linger. 

**Add the following code immediately after your previous call to `MultilineTypewriteTextInHL_AtDE` with `Story.Line1`**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:between-pages}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:between-pages}}
```

After we've shown the first page and cleared the background, we'll do the same thing for page 2:

**Add this second implementation of the `MultilineTypewriteTextInHL_AtDE` function to draw the second page of our story:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page2}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page2}}
```

With our story full shown, once the player presses the A button, we're ready to move onto the next game state: Gameplay. We'll end our `UpdateStoryState` function by updating our game state variable and jump back to the `NextGameState` label like previously discussed.

**Complete the story state and our `UpdateStoryState` function using the code below:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-end}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-end}}
```
