# Project Structure

For organizational purposes, many parts of the logic are separated into reusable functions. This is to reduce duplicate code, and make logic more clear.

Here’s a basic look at how the project is structured:

::: tip

Generated files should never be included in VCS repositories. It unneccessarily bloats the repo. The folders below marked with \* contains assets generated from running the Makefile and are not included in the repository.

:::

- `libs` - Two assembly files for input and sprites are located here.
- `src`
  - `generated` - the results of RGBGFX are stored here. \*
  - `resources` - Here exist some PNGs and Aseprite files for usage with RGBGFX
  - `main` - All assembly files are located here, or in subfolders
    - `states`
      - `gameplay` - for gameplay related files
        - `objects` - for gameplay objects like the player, bullets, and enemies
          - collision - for collision among objects
      - `story` - for our story state's related files
      - `title-screen` - for our title screen's related files
    - `utils` - Extra functions includes to assist with development
      - `macros`
- `dist` - The final ROM file will be created here. \*
- `obj` - Intermediate files from the compile process. \*
- `Makefile` - used to create the final ROM file and intermediate files

At the root of the project's [github repository](https://github.com/gbdev/gb-asm-tutorial/tree/master/galactic-armada), you'll notice only 2 folders (`src`, and `lib`) and 1 file (the [makefile](https://github.com/gbdev/gb-asm-tutorial/blob/master/galactic-armada/Makefile)). Locally, if you run the makefile, you'll see the `dist` and `obj` folders will be generated.