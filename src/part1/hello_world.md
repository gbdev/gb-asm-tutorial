# Hello World!

In this lesson, we will begin by assembling our first program.
The rest of this chapter will be dedicated to explaining how and why it works.

Note that we will need to type a lot of commands, so open a terminal now.
It's a good idea to create a new directory (`mkdir gb_hello_world`, for example, then `cd gb_hello_world` to enter the new directory).

Grab the following files (right-click each link, "Save Link As..."), and place them all in this new directory:
- [`hello-world.asm`](../assets/hello-world.asm)
- [`hardware.inc`](https://raw.githubusercontent.com/gbdev/hardware.inc/v4.0/hardware.inc)

Then, still from a terminal within that directory, run the following three commands.

::: warning:⚠️

To clarify where each individual command begins, I've added a `$` before each command, but don't type them!

:::

```console
$ rgbasm -L -o hello-world.o hello-world.asm
$ rgblink -o hello-world.gb hello-world.o
$ rgbfix -v -p 0xFF hello-world.gb
```

<style>
	.box.danger ol {
		list-style-type: symbols(fixed "👎" "👍" "👍");
	}
</style>

::: danger:‼️

Be careful with arguments! Some options, such as `-o` here, use the argument after them as a parameter:

1. `rgbasm -L -o hello-world.asm hello-world.o` won't work (and may corrupt `hello-world.asm`!)
2. `rgbasm -L hello-world.asm -o hello-world.o` will work
3. `rgbasm hello-world.asm -o hello-world.o -L` will also work

If you need whitespace within an argument, you must quote it:

1. `rgbasm -L -o hello world.o hello world.asm` won't work
2. `rgbasm -L -o "hello world.o" "hello world.asm"` will work

:::

It should look like this:
<script id="asciicast-weljUlcp1KC5GqS9jqV62dy5m" src="https://asciinema.celforyon.fr/a/weljUlcp1KC5GqS9jqV62dy5m.js" async></script>

(If you encounter an error you can't figure out by yourself, don't be afraid to [ask us](../index.md#feedback)! We'll sort it out.)

Congrats!
You just assembled your first Game Boy ROM!
Now, we just need to run it; open Emulicious, then go "File", then "Open File", and load `hello-world.gb`.

<video controls poster="../assets/vid/hello_world.poster.png">
	<source src="../assets/vid/hello_world.webm" type="video/webm">
	<source src="../assets/vid/hello_world.mp4" type="video/mp4">

	<img src="../assets/vid/hello_world.gif" alt="Video demonstration in Emulicious">
</video>

You could also take a flash cart (I use the [EverDrive GB X5](https://krikzz.com/store/home/47-everdrive-gb.html), but there are plenty of alternatives), load up your ROM onto it, and run it on an actual console!

![Picture of the Hello World running on a physical DMG](../assets/img/hello_dmg.jpg)

Well, now that we have something working, it's time to peel back the curtains...
