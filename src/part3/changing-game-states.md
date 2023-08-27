# Changing Game States

In our GalacticArmada.asm file, we'll define label called "NextGameState". Our game will have 3 game states:

- Title Screen
- Story Screen
- Gameplay

Here is how they will flow:

![Game States Visualized.png](../assets/part3/img/Game_States_Visualized.png)

When one game state wants to go to another, it will need to change our previously declared 'wGameState' variable and then jump to the "NextGameState" label. There are some common things we want to accomplish when changing game states:

(during a Vertical Blank)

- Turn off the LCD
- Reset our Background & Window positions
- Clear the Background
- Disable Interrupts
- Clear All Sprites
- Initiate our NEXT game state
- Jump to our NEXT game state's (looping) update logic

> It will be the responsibility of the "init" function for each game state to turn the LCD back on.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/GalacticArmada.asm:next-game-state}}
{{#include ../../galactic-armada/src/main/GalacticArmada.asm:next-game-state}}
```

The goal here is to ( as much as possible) give each new game state a _blank slate_ to start with.

That's it for the GalacticArmada.asm file.
