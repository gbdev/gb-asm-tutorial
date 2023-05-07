# Enemy-Player Collision

Our enemy versus player collision detection starts with us getting our player's unscaled x position. We'll store that value in d.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:get-player-x}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:get-player-x}}
```

We'll check

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:get-y}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:get-y}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:check-x-overlap}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:check-x-overlap}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:check-y-overlap}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:check-y-overlap}}
```
```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:result}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/collision/enemy-player-collision.asm:result}}
```