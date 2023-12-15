# The Player

The player’s logic is pretty simple. The player can move in 4 directions and fire bullets. We update the player by checking our input directions and the A button. We’ll move in the proper direction if its associated d-pad button is pressed. If the A button is pressed, we’ll spawn a new bullet at the player’s position.

**Create a new file named "player.asm"**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-start}}
```

Our player isn't going to need any special variables. All variables needed have already been setup. 

## Initializing the Player

When gameplay starts, we need to initialize the player. 
* Set the player's object struct as active (so nothing else takes it's spot)
* Position the player in the middle of the screen
* Set the player's metasprite to draw with
* Set the player's health
* Set the player's update function

**Copy the following `InitializePlayer` function into player.asm**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-initialize}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-initialize}}
```

## Updating the Player

For our player's update function, we just check for joypad input and handle it accordingly.
- Move in any direction pressed
- Fire a bullet if the a button is pressed

**Copy this `UpdatePlayer` function into your player.asm file**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-update-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-update-start}}
```

Our movement functions should all look very similar. Since our player is the first object of the `wObjects` array, we can access it's positional bytes using constants from constants.inc:
- y low byte = wObjects+object_yLowByte
- y high byte = wObjects+object_yHighByte
- x low byte = wObjects+object_xLowByte
- x high byte = wObjects+object_xHighByte

> **Note:** Our x & y positions are Q12.4 Fixed-Point integers. We'll increase the low byte first, and then apply the carry over to the high byte.

**Copy the following `Move<Up/Down/Right/Left>` functions into player.asm**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-movement}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-movement}}
```

We'll go over the `FireNextBullet` function next, on the [bullets](#bullets) page.
## Damaging the player

When the player is damaged we'll decrease it's health byte, and set it's damage byte to 128. Recall, when our damage byte is non-zero the object will blink.

**Finish your player.asm by copying the `DamagePlayer` function to it**

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-damage}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/player.asm:player-damage}}
```

That's everything for our player. Next, we'll go over bullets and then onto the enemies.