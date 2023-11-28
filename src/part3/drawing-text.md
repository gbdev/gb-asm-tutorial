# Drawing Text

## Mapping Characters to bytes

## Drawing Basic Text

You can find this function in the ["src/main/utils/text-utils.asm"](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/src/main/utils/text-utils.asm) file: 

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/text-utils.asm:draw-text-tiles}}
{{#include ../../galactic-armada/src/main/utils/text-utils.asm:draw-text-tiles}}
```

## Animating Text with a Typewriter effect


For this effect, we've defined a function in our "src/main/utils/text-utils.asm" file:

```rgbasm,linenos,start={{#line_no_of "" ../../galactic-armada/src/main/utils/text-utils.asm:typewriter-effect}}
{{#include ../../galactic-armada/src/main/utils/text-utils.asm:typewriter-effect}}
```

## Animating multiple lines with a Typewriter Effect