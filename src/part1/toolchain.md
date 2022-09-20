# The toolchain

So, in the previous lesson, we built a nice little "Hello World!" ROM.
Now, let's find out exactly what we did.

## RGBASM and RGBLINK

Let's begin by explaining what `rgbasm` and `rgblink` do.

RGBASM is an *assembler*.
It is responsible for reading the source code (in our case, `hello-world.asm` and `hardware.inc`), and generating blocks of code with some "holes".
RGBASM does not always have enough information to produce a full ROM, so it does most of the work, and stores its intermediary results in what's known as *object files* (hence the `.o` extension).

RGBLINK is a *linker*.
Its job is taking object files (or, like in our case, just one), and "linking" them into a ROM, which is to say: filling the aforementioned "holes".
RGBLINK's purpose may not be obvious with programs as simple as this Hello World, but it will become much clearer in Part Ⅱ.

So: Source code → `rgbasm` → Object files → `rgblink` → ROM, right?
Well, not exactly.

## RGBFIX

RGBLINK does produces a ROM, but it's not quite usable yet.
See, actual ROMs have what's called a *header*.
It's a special area of the ROM that contains [metadata about the ROM](https://gbdev.io/pandocs/The_Cartridge_Header.html); for example, the game's name, Game Boy Color compatibility, and more.
For simplicity, we defaulted a lot of these values to 0 for the time being; we'll come back to them in Part Ⅱ.

However, the header contains three crucial fields:
- The [Nintendo logo](https://gbdev.io/pandocs/The_Cartridge_Header.html#0104-0133--nintendo-logo),
- the [ROM's size](https://gbdev.io/pandocs/The_Cartridge_Header.html#0148--rom-size),
- and [two checksums](https://gbdev.io/pandocs/The_Cartridge_Header.html#014d--header-checksum).

When the console first starts up, it runs [a little program](https://github.com/ISSOtm/gb-bootroms) known as the *boot ROM*, which reads and draws the logo from the cartridge, and displays the little boot animation.
When the animation is finished, the console checks if the logo matches a copy that it stores internally; if there is a mismatch, **it locks up!**
And, since it locks up, our game never gets to run... 😦
This was meant as an anti-piracy measure; however, that measure [has since then been ruled as invalid](https://en.wikipedia.org/wiki/Sega_v._Accolade), so don't worry, we are clear! 😄

Similarly, the boot ROM also computes a *[checksum](https://en.wikipedia.org/wiki/Checksum)* of the header, supposedly to ensure that it isn't corrupted.
The header also contains a copy of this checksum; if it doesn't match what the boot ROM computed, then the boot ROM **also locks up!**

The header also contains a checksum over the whole ROM, but nothing ever uses it.
It doesn't hurt to get it right, though.

Finally, the header also contains the ROM's size, which is required by emulators and flash carts.

RGBFIX's role is to fill in the header, especially these 3 fields, which are required for our ROM to be guaranteed to run fine.
The `-v` option instructs RGBFIX to make the header **v**alid, by injecting the Nintendo logo and computing the two checksums.
The `-p 0xFF` option instructs it to **p**ad the ROM to a valid size, and set the corresponding value in the "ROM size" header field.

Alright!
So the full story is: Source code → `rgbasm` → Object files → `rgblink` → "Raw" ROM → `rgbfix` → "Fixed" ROM.
Good.

You might be wondering why RGBFIX's functionality hasn't been included directly in RGBLINK.
There are some historical reasons, but RGBLINK can also be used to produce things other than ROMs (especially via the `-x` option), and RGBFIX is sometimes used without RGBLINK anywhere in sight.

## File names

Note that RGBDS does not care at all about the files' extensions.
Some people call their source code `.s`, for example, or their object files `.obj`.
The file names don't matter, either; it's just practical to keep the same name.
