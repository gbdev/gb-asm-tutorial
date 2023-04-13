# Gameplay State

In this game state, the player will control a spaceship. Flying over a vertically scrolling space background. They’ll be able to freely move in 4 directions , and shoot oncoming alien ships. As alien ships are destroyed by bullets, the player’s score will increase.

![rgbds-shmup-gameplay.gif](../assets/part3/img/rgbds-shmup-gameplay.gif)

Gameplay is the core chunk of the source code. It also took the most time to create. Because of such, this game state has to be split into multiple sub-pages. Each page will explain a different gameplay concept.

## When Gameplay Starts:

When gameplay starts the player's score is reset to 0, and the player's lives are set to 0. In addition ,we do all of the following:
- Enable STAT interrupts for the HUD
- Load our Star Field into VRAM and draw it on the background
- Draw our "score" & "lives" text on the window.
- Turn the LCD on with the window enabled at $9C00
- Initiliaize our player, enemies, and bullets

## The Gameplay Loop

During gameplay, we do all of the following:
- Poll for input
- Reset our Shadow OAM
- Update and Draw the player
- Update and Draw each enemy (checking against each bullet)
- Update and Draw bullets
- Remove any unused sprites from the screen
- Scroll the background

### Vertical Blank Phase

When the vertical blank phase starts, we check if the player has lost all of their lives. If so, we end gameplay. 

If the player is stil alive, we copy our Shadow OAM sprites into VRAM.  See https://github.com/eievui5/gb-sprobj-lib

## Game Over
Every time the player collides with an enemy, the player flashes and loses a life. Gameplay ends when the player loses all their lives. In such event, the game goes back to the Title Screen game state.