# The Player

The player’s logic is pretty simple. The player can move in 4 directions and fire bullets. We update the player by checking our input directions and the A button. We’ll move in the proper direction if its associated d-pad button is pressed. If the A button is pressed, we’ll spawn a new bullet at the player’s position.

Our player will have 3 variables:
- wePlayerPositionX - a 16-bit scaled integer
- wePlayerPositionY - a 16-bit scaled integer
- wPlayerFlash - a 16-bit integer used when the player gets damaged

> ⚠️ **NOTE**: The player can move vertically AND horizontally. So, unlike bullets and enemies, it’s x position is a 16-bit scaled integer.

These are declared at the top of the "src/main/states/gameplay/objects/player.asm" file

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-start}}
```

Well draw our player, a simple ship, using the previously discussed metasprites implementation. Here is what we have for the players metasprites and tile data:
```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-data}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-data}}
```

## Initializing the Player

Initializing the player is pretty simple. Here's a list of things we need to do:
* Reset oir wPlayerFlash variable
* Reset our wPlayerPositionX variable
* Reset our wPlayerPositionU variable
* Copy the player's ship into VRAM

We'll use a constant we declared in "src/main/utils/constants.inc" to copy the player ship's tile data into VRAM. Our enemy ship and player ship both have 4 tiles (16 bytes for each tile). In the snippet below, we can define where we'll place the tile data in VRAM relative to the _VRAM constant:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/constants.inc:sprite-vram-constants}}
{{#include ../../galactic-armada/src/main/utils/constants.inc:sprite-vram-constants}}
```

Here's what our "InitializePlayer" function looks like. Recall, this was called when initiating the gameplay game state:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-initialize}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-initialize}}
```

## Updating the Player

We can break our player's update logic into 2 parts:
* Check for joypad input,  move with the d-pad, shoot with A
* Depending on our "wPlayerFlash" variable: Draw our metasprites at our location

Checking the joypad is done like the previous tutorials, we'll perform bitwise "and" operations with constants for each d-pad direction.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-update-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-update-start}}
```

For player movement, our X & Y are 16-bit integers. These both require two bytes. There is a little endian ordering, the first byte will be the low byte. The second byte will be the high byte. To increase/decrease these values, we add/subtract our change amount to/from the low byte. Then afterwards, we add/subtract the remainder of that operation to/from the high byte.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-movement}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-movement}}
```

When the player wants to shoot, we first check if the A button previously was down. If it was, we won't shoot a new bullet. This avoids bullet spamming a little. For spawning bullets, we have a function called "FireNextBullet". This function will need the new bullet's 8-bit X coordinate and 16-bit Y coordinate, both set in a variable it uses called "wNextBullet"

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-shoot}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-shoot}}
```

After we've potentially moved the player and/or shot a new bullet. We need to draw our player. However, to create the "flashing" effect when damaged, we'll conditionally NOT draw our player sprite. We do this based on the "wPlayerFlash" variable.

- If the "wPlayerFlash" variable is 0, the player is not damaged, we'll skip to drawing our player sprite.
- Otherwise, decrease the "wPlayerFlash" variable by 5.
    - We'll shift all the bits of the "wPlayerFlash" variable to the right 4 times
    - If the result is less than 5, we'll stop flashing and draw our player metasprite.
    - Otherwise, if the first bit of the decscaled "wPlayerFLash" variable is 1, we'll skip drawing the player.

> ***NOTE:** The following resumes from where the "UpdatePlayer_HandleInput" label ended above.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-update-flashing}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-update-flashing}}
```

If we get past all of the "wPlayerFlash" logic, we'll draw our player using the "DrawMetasprite" function we previously discussed.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-update-sprite}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-update-sprite}}
```

That's the end our our "UpdatePlayer" function. The final bit of code for our player handles when they are damaged. When an enemy damages the player, we want to decrease our lives by one. We'll also start flashing  by giving our 'mPlayerFlash' variable a non-zero value. In the gameplay game state, if we've lost all lives, gameplay will end.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-damage}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-damage}}
```

That's everything for our player. Next, we'll go over bullets and then onto the enemies.