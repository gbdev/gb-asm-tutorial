# Enemies

Enemies in SHMUPS often come in a variety of types, and travel also in a vareity of patterns. To keep things simple for this tutorial, we'll have one enemy that flys straight downward. Because of this decision, the logic for enemies is going to be very similar to bullets.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-start}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-tile-metasprite}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-tile-metasprite}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-initialize}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-initialize}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-start}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-start}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-loop}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-loop}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-per-enemy}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-per-enemy}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-per-enemy2}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-per-enemy2}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-deactivate}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-deactivate}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-collision}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-collision}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-nocollision}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-update-nocollision}}
```

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-spawn}}
{{#include ../../galactic-armada/src/main/states/gameplay/objects/enemies.asm:enemies-spawn}}
```
 