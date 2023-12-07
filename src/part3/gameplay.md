# Gameplay State

In this game state, the player will control a spaceship. Flying over a vertically scrolling space background. They’ll be able to freely move in 4 directions , and shoot oncoming alien ships. As alien ships are destroyed by bullets, the player’s score will increase.

![rgbds-shmup-gameplay.gif](../assets/part3/img/rgbds-shmup-gameplay.gif)

Gameplay is the core chunk of the source code. It also took the most time to create. Because of such, this game state has to be split into multiple sub-pages. Each page will explain a different gameplay concept.

**Create `gameplay-state.asm`, and add the following data and variables:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:gameplay-data-variables}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:gameplay-data-variables}}
```

For simplicity reasons, our score uses 6 bytes. Each byte repesents one digit in the score.

## Initiating the Gameplay Game State:

When gameplay starts we want to do all of the following:
- reset the player's score to 0
- reset the player's lives to 3. 
- Initialize all of our object pool
- Clear the background and any existing sprites
- Setup VRAM with the neccessary tile data
- Enable STAT interrupts for the HUD
- Draw our "score" & "lives"  on the HUD.
- Reset the window's position back to 7,0
- Enable the window using the tilemap at $9C00

>**Note:** Object pools will be covered in the next page.

**Copy the following code to the bottom of your `gameplay-state.asm` file**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:init-gameplay-state}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:init-gameplay-state}}
```

The initialization logic for our the background, the player, the enemies, the bullets will be explained in later pages. Every game state is responsible for turning the LCD back on. The gameplay game state needs to use the window layer, so we'll make sure that's enabled before we return.

## Updating the Gameplay Game State

Our "UpdateGameplayState" function doesn't have very complicated logic. Most of the logic has been split into separate files for the background, player, enemies, and bullets.

During gameplay, we do all of the following:
* Try to spawn enemies
* Update our object pool
* Update our Background
* Check our player's health, if it's gone below zero we'll end gameplay
  
**Copy the following code to the bottom of your `gameplay-state.asm` file**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-state}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-state}}
```

Ending gameplay is very simple, we'll do the same thing we did to transition TO gameplay (from the story screen). We'll simply put the address of the title screen's init & update functions inside of our `wNextGameState_Initiate` and `wNextGameState_Update` variables.

**Copy the following code to the bottom of your `gameplay-state.asm` file**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:end-gameplay-state}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:end-gameplay-state}}
```
That's it for gameplay, next we'll go over object pools.