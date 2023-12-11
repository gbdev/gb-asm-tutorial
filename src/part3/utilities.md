# Utilties


## Waiting for Buttons to be pressed

Our "WaitForKeyFunction" is defined in [ "src/main/utils/input-utils.asm"](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/src/main/utils/input-utils.asm). We'll poll for input and infinitely loop until the specified button is pressed down.

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/input-utils.asm:input-utils}}
{{#include ../../galactic-armada/src/main/utils/input-utils.asm:input-utils}}
```

## Clearing the background 

Once the user presses the A button, we want to show the second page. To avoid any lingering "leftover" letters, we'll clear the background. All this function does is turn off the LCD, fill our background tilemap with the first tile, then turn back on the lcd. We've defined this function in the "src/main/utils/background.utils.asm" file:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/background-utils.asm:background-utils}}
{{#include ../../galactic-armada/src/main/utils/background-utils.asm:background-utils}}
```