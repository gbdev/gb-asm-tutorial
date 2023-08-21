# Enemy-Player Collision

Our enemy versus player collision detection starts with us getting our player's unscaled x position. We'll store that value in d.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:get-player-x}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:get-player-x}}
```

With our player's x position in d, we'll compare it against a previously saved enemy x position variable. If they are more than 16 pixels apart, we'll jump to the "NoCollisionWithPlayer" label.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:check-x-overlap}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:check-x-overlap}}
```

After checking the x axis, if the code gets this far there was an overlap. We'll do the same for the y axis next.

We'll get the player's unscaled y position. We'll store that value in d for consistency.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:get-y}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:get-y}}
```

Just like before, we'll compare our player's unscaled y position (stored in d) against a previously saved enemy y position variable. If they are more than 16 pixels apart, we'll jump to the "NoCollisionWithPlayer" label. 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:check-y-overlap}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:check-y-overlap}}
```

The "NoCollisionWithPlayer", just set's the "wResult" to 0 for failure. If overlap occurs on both axis, we'll isntead set 1 for success.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:result}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:result}}
```

That's the enemy-player collision logic. Callers of the function can simply check the "wResult" variable to determine if there was collision.