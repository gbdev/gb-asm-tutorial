# Gameplay State

In this game state, the player will control a spaceship. Flying over a vertically scrolling space background. They’ll be able to freely move in 4 directions , and shoot oncoming alien ships. As alien ships are destroyed by bullets, the player’s score will increase.

![rgbds-shmup-gameplay.gif](../assets/part3/img/rgbds-shmup-gameplay.gif)

Gameplay is the core chunk of the source code. It also took the most time to create. Because of such, this game state has to be split into multiple sub-pages. Each page will explain a different gameplay concept.

Our gameplay state defines the following data and variables:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:gameplay-data-variables}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:gameplay-data-variables}}
```

For simplicity reasons, our score uses 6 bytes. Each byte repesents one digit in the score.

## Initiating the Gameplay Game State:

When gameplay starts we want to do all of the following:
- reset the player's score to 0
- reset the player's lives to 3. 
- Initialize all of our gameplay elements ( background, player, bullets, and enemies)
- Enable STAT interrupts for the HUD
- Draw our "score" & "lives"  on the HUD.
- Reset the window's position back to 7,0
- Turn the LCD on with the window enabled at $9C00

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:init-gameplay-state}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:init-gameplay-state}}
```

The initialization logic for our the background, the player, the enemies, the bullets will be explained in later pages. Every game state is responsible for turning the LCD back on. The gameplay game state needs to use the window layer, so we'll make sure that's enabled before we return.

## Updating the Gameplay Game State

Our "UpdateGameplayState" function doesn't have very complicated logic. Most of the logic has been split into separate files for the background, player, enemies, and bullets.

During gameplay, we do all of the following:
* Poll for input
* Reset our Shadow OAM
* Reset our current shadow OAM sprite
* Update our gameplay elements (player, background, enemies, bullets, background)
* Remove any unused sprites from the screen
* End gameplay if we've lost all of our lives
* inside of the vertical blank phase
    * Apply shadow OAM sprites 
    * Update our background tilemap's position

We'll poll for input like in the previous tutorial. We'll always save the previous state of the gameboy's buttons in the "wLastKeys" variable.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-state-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-state-start}}
```

Next, we'll reset our Shadow OAM and reset current Shadow OAM sprite address. 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-oam}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-oam}}
```

Because we are going to be dealing with a lot of sprites on the screen, we will not be directly manipulating the gameboy's OAM sprites. We'll define a set of "shadow" (copy") OAM sprites, that all objects will use instaed. At the end of the gameplay looop, we'll copy the shadow OAM sprite objects into the hardware.

Each object will use a random shadow OAM sprite. We need a way to keep track of what shadow OAM sprite is being used currently. For this, we've created a 16-bit pointer called "wLastOAMAddress". Defined in "src/main/utils/sprites.asm", this points to the data for the next inactive shadow OAM sprite. 

When we reset our current Shadow OAM sprite address, we just set the "mLastOAMAddress" RAM variable to point to the first shadow OAM sprite. 

> **NOTE:** We also keep a counter on how many shadow OAM sprites are used. In our "ResetOAMSpriteAddress" function, we'll reset that counter too.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/sprites-utils.asm:reset-oam-sprite-address}}
{{#include ../../galactic-armada/src/main/utils/sprites-utils.asm:reset-oam-sprite-address}}
```

Next we'll update our gameplay elements:
```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-elements}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-elements}}
```

After all of that, at this point in time, the majority of gameplay is done for this iteration. We'll clear any remaining spirtes. This is very necessary becaus the number of active sprites changes from frame to frame. If there are any visible OAM sprites left onscreen, they will look weird and/or mislead the player. 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-clear-sprites}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-clear-sprites}}
```

The clear remaining sprites function, for all remaining shadow OAM sprites, moves the sprite offscreen so they are no longer visible. This function starts at wherever the "wLastOAMAddress" variable last left-off.

#### End of The Gameplay loop

At this point in time, we need to check if gameplay needs to continue. When the vertical blank phase starts, we check if the player has lost all of their lives. If so, we end gameplay. We end gameplay similar to how we started it, we'll update our 'wGameState' variable and jump to "NextGameState".

If the player hasn't lost all of their lives, we'll copy our shadow OAM sprites over to the actual hardware OAM sprites and loop background.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-end-update}}
{{#include ../../galactic-armada/src/main/states/gameplay/gameplay-state.asm:update-gameplay-end-update}}
```