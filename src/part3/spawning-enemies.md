# Spawning Enemies

For spawning enemies, we increase a counter each frame. When this counter reaches a set value, we’ll TRY to spawn an enemy. If an enemy is actual spawned, we’ll reset the counter. When trying to spawn a value, we’ll get a random unsigned 8-bit number. This number will be the enemies x posittion. From: [https://github.com/pinobatch/libbet/blob/master/src/rand.z80#L34-L54](https://github.com/pinobatch/libbet/blob/master/src/rand.z80#L34-L54) 


```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:rand}}
{{#include ../../galactic-armada/main.asm:rand}}
```

 The only time we’ll fail to spawn an enemy is when this value is not in a acceptable range (offscreen fully or partially). If we succeed, we loop through the enemy object pool and activate the first inactive enemy.