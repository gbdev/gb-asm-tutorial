# GB ASM tutorial

A book that teaches how to develop games for the Game Boy and Game Boy Color using assembly language and the RGBDS toolchain.

You can read it at https://gbdev.io/gb-asm-tutorial/.

## Contributing 

Contributing is really easy, fork this repo and edit the files in the **src** directory. Then, you can send your PR.

To deploy gb-asm-tutorial locally:

1. Install [Rust](https://www.rust-lang.org/tools/install) and [mdBook](https://github.com/rust-lang/mdBook#readme) (v0.4.x).
  mdBook powers the book itself, Rust is used for some custom plugins.
  ```bash
  $ cargo install mdbook@0.4.52
  ```
2. Within a terminal pointed at the directory `book.toml` is in, run mdBook commands:

```bash
# Watches the book's src directory for changes, rebuild the book, serve it on localhost:3000
#  and refresh clients for each change.
mdbook serve

# Produce a build in `book/custom/`
mdbook build
# Watch your files and trigger a build automatically whenever you modify a file.
mdbook watch
```

## Translating

To help translate the tutorial, join the [project on Crowdin](https://crowdin.com/project/gb-asm-tutorial).

## License

Different parts of gb-asm-tutorial are subject to different licenses:

- All the code contained within the tutorial itself is licensed under <a rel="license" href="http://creativecommons.org/publicdomain/zero/1.0/">CC0</a>. *To the extent possible under law, all copyright and related or neighboring rights to code presented within GB ASM Tutorial have been waived. This work is published from France.*
- The contents (prose, images, etc.) of this tutorial are licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
- Code used to display and format the site is licensed under the [MIT License](https://github.com/gbdev/gb-asm-tutorial/blob/master/LICENSE) unless otherwise specified.
- The code related to the i18n support is originally from Google's [Comprehensive Rust](https://github.com/google/comprehensive-rust) and is released under the [Apache License 2.0](https://github.com/gbdev/gb-asm-tutorial/blob/master/i18n-helpers/LICENSE).

