# Story Screen

The story screens shows a basic generic story on 2 pages. Afterwards it sends the player to the gameplay game state.

![GalacticArmada-1.png](../assets/part3/img/GalacticArmada-1.png)
![GalacticArmada-2.png](../assets/part3/img/GalacticArmada-2.png)

## Initiating up the Story Screen

The "InitStoryState" does not have any logic in it. We're just going to turn on the LCD and that's it. The reason for this is that most of this game state's logic will occur in it's update function.

> **NOTE:** The text macros file is included so our story text has the proper character maps.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:init-story-state}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:init-story-state}}
```

## Updating the Story Screen

Here's the data for our story screen. We have this defined just above our "UpdateStoryState" function:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-data}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-data}}
```

The story text is shown using a typewriter effect. This effect is done the same way the “press a to play” text was done before. Except, we are waiting 3 vertical blank phases between writing each letter. Which gives a small delay. 

> You could bind this to a variable and make it configurable via an options screen too!

For this effect, we've defined a function in our "src/main/utils/text-utils.asm" file:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/text-utils.asm:typewriter-effect}}
{{#include ../../galactic-armada/src/main/utils/text-utils.asm:typewriter-effect}}
```

We use that function in the "UpdateStoryState" function, by setting two things:
* in de: what background tilemap address we want to start writing letters at
* in hl: the address to the start of the current line

We'll do that four times for the first page, and then wait for the A button to be pressed:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page1}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page1}}
```
Once the user presses the A button, we want to show the second page. To avoid any lingering "leftover" letters, we'll clear the background. All this function does is turn off the LCD, fill our background tilemap with the first tile, then turn back on the lcd. We've defined this function in the "src/main/utils/background.utils.asm" file:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/background-utils.asm:background-utils}}
{{#include ../../galactic-armada/src/main/utils/background-utils.asm:background-utils}}
```

Getting back to our Story Screen: After we've shown the first page and cleared the background, we'll do the same thing for page2:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page2}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-page2}}
```

With our story full shown, we're ready to move onto the next game state: Gameplay. We'll end our "UpdateStoryState" function by updating our game state variable and jump back to the "NextGameState" label like previously discussed.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-end}}
{{#include ../../galactic-armada/src/main/states/story/story-state.asm:story-screen-end}}
```

The next & final game state to cover is gameplay. This has the biggest amount of logic and source files, so it will be orgnized into sub pages on the sidebar.