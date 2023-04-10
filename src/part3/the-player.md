# The Player

The player’s logic is pretty simple. The player can move 4 directions and fire bullets. When updating the player, we check our input directions and the A button. We’ll move in the proper direction if it’s associated d-pad button was pressed. If the a button was JUST pressed, we’ll spawn a new bullet at the player’s position.

> For getting input, code from the first RGBDS assembly tutorial is used: [https://gbdev.io/gb-asm-tutorial/part2/input.html](https://gbdev.io/gb-asm-tutorial/part2/input.html) . Simply put, getting joypad input from the hardware is as straightforward as one might think. Thus it’s best to stick with tried and true code.

The RGBDS documentation and tutorial come with an awesome [hardware.inc](http://hardware.inc) file for you to use. This file defines constants for almost the entire gameboy hardware. In this file, there are constants used for each button.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:joypad-constants}}
{{#include ../../galactic-armada/main.asm:joypad-constants}}
```

> ⚠️ **NOTE**: The player can move vertically AND horizontally. So, unlike bullets and enemies, it’s x position is a 16-bit scaled integer.

After testing each direction, and the “A” button, we simply update the player’s sprite position. This is done using the previously mentioned custom metasprite implementation

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/main.asm:update-player}}
{{#include ../../galactic-armada/main.asm:update-player}}
```