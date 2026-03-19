# Title Screen

Let's make our game more official and give it a title screen! First, copy the tileset and tilemap found [here](https://github.com/gbdev/gb-asm-tutorial/raw/master/unbricked/title-screen/tilemap-titlescreen.asm) and paste it at the end of your code. This will make a title screen that looks like so: 

<img
  class="pixelated"
  src="../assets/part2/img/title-screen.png"
  alt="Title Screen"
/>

Then copy and paste the following after waiting for VBlank:

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/title-screen/main.asm:title_screen}}
{{#include ../../unbricked/title-screen/main.asm:title_screen}}
```
Note that we are using our `Memcopy` function from the [Functions](./functions.md) lesson! Isn't it handy to have reusable code? We are also using our `UpdateKeys` function from the [Input](./input.md) lesson to determine when to stop displaying the title screen and move on to the game itself. To do so, we loop until the start button has been pressed. 

And just like that we have ourselves a title screen! 

## Organizing Our Code
Our project is getting quite large with all the functionality we're building in! Let's briefly go over how to better organize things. Until now, we have always added new code into the same assembly file (`main.asm`). This file can get pretty large if we're not careful, making it harder to read and maintain. Instead, RGBDS has a handy feature for making [functions](./functions.md) or other labels visible to external files. This will help our codebase be nice and clean, making it more manageable (in the case where one might collaborate with others, this is essential!). As an example, let's take everything we added in our [input](./input.md) lesson, and put it in a separate file named [`input.asm`](https://github.com/gbdev/gb-asm-tutorial/raw/master/unbricked/title-screen/input.asm). 

Notice the use of the double colon (`::`) after the function and variable names. This is how we can export a label to other files, also known as broadening its [scope](https://en.wikipedia.org/wiki/Scope_%28computer_programming%29). Now that we have all of the input-related code in a separate file, and everything else in main, all that is left is to build the ROM. Now that we have multiple files, we have to assemble each assembly file, then link them together in one ROM, like so:

```console,linenos,start={{#line_no_of "" ../../unbricked/title-screen/build.sh:multibuild}}
{{#include ../../unbricked/title-screen/build.sh:multibuild}}
```

Try doing the same with other assembly files to keep your code nice and tidy. Break up separate functionality into other files, don't forget to assemble them separately, then link them all together! 
