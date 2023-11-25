# Changing Game States

In our [GalacticArmada.asm](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/src/main/GalacticArmada.asm) file, we'll define label called "NextGameState". Our game will have 3 game states:

- Title Screen
- Story Screen
- Gameplay

Here is how they will flow:

![Game States Visualized.png](../assets/part3/img/Game_States_Visualized.png)

This page will show you how to setup basic game state management. 

## Setting up Game State Management

First thing we'll do is setup 3 variables in working ram. 
- **wCurrentGameState_Update** - the address of the current game state's update function
- **wNextGameState_Initiate** - If we are changing game states, this will be non-zero. In that case, it will be the address of the "initiate" function for that game state.
- **wNextGameState_Update** - If we are changing game states, this will be non-zero. In that case, it will be the address of the "update" function for that game state. It will overwrite the `wCurrentGameState_Update` variable after the above `wNextGameState_Initiate` is called.

**Create those 3 variables as "words" at the top of our GalacticArmada.asm file, in the working ram section titled "GameVariables":**

```rgbasm, linenos
SECTION "GameVariables", WRAM0

; ... Existing GameVariables

{{#include ../../galactic-armada/src/main/GalacticArmada.asm:game-state-variables}}

```

**Next, after the entry point label: default each of those to 0 at the start of our game.**

```rgbasm, linenos
EntryPoint:

{{#include ../../galactic-armada/src/main/GalacticArmada.asm:initialize-game-state-variables}}

    ; ... Existing EntryPoing logic

```

Now we have to setup and implement those variables. To do that, we'll utilize the following functions: (that we haven't yet created)
- **InitiateNewGameStates** - This will initialize the new game state, if we are changing game states.
- **UpdateCurrentGameState** - This will update the current game state, if it exists.

**In the `GalacticArmadaGameLoop` function, after we call `ResetShadowOAM` add calls to those 2 functions**

```rgbasm, linenos
GalacticArmadaGameLoop:

	; ... calling 'Input' and `ResetShadowOAM`

{{#include ../../galactic-armada/src/main/GalacticArmada.asm:update-game-state-management}}

    ; ... waiting for VBlank start, before calling `hOAMDMA` and looping.
```

These 2 functions haven' been created yet, we'll do that next.

### Initiate New Game States

We previously created a `wNextGameState_Initiate` variable. This variable will be used to hold an address. That address will point to the initiation logic for the next game state. If this variable is 0, then the game is NOT changing game states. If the variable is NOT 0, then we'll call the function it specifies.

After we've called that initiate function, we'll update our `wCurrentGameState_Update` variable. We'll override it's current value, with the value specified in our other variable: `wNextGameState_Update`. This will tell the game to start calling the new game state's update logic instead of our curernt/old one.

With those changes done, we'll reset our `wNextGameState_Initiate` and `wNextGameState_Update` variables back to 0. This will prevent the initiation logic from executing again until we change the game state.

**Create this function at the bottom of the GalacticArmada.asm file:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/GalacticArmada.asm:initiate-new-game-state-function}}
{{#include ../../galactic-armada/src/main/GalacticArmada.asm:initiate-new-game-state-function}}
```


### Updating the current Game State

For updating the current game state, we'll get the address in our `wCurrentGameState_Update` variable. If it's 0, we'll return early. Otherwise, we'll call the function located at that address and return when the function is done.

**Create this function at the bottom of the GalacticArmada.asm file:**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/GalacticArmada.asm:update-current-game-state-function}}
{{#include ../../galactic-armada/src/main/GalacticArmada.asm:update-current-game-state-function}}
```

## Setting up a default game state

We've got one final task for the GalacticArmada.asm file. Setting up a default game state. 

That task won't be done yet. In the next page, you'll create the title screen. Once we've fully setup that game state, we'll come back to the GalacticArmada.asm file and specify it as our default game state.