# GB ASM tutorial (v2)

Re-doing [GB ASM Tutorial](https://github.com/ISSOtm/gb-asm-tutorial-old), and this time, until the end.

## Translating

To help translate the tutorial, join the [project on Crowdin](https://crowdin.com/project/gb-asm-tutorial).

## Contributing 

Contributing is really easy, fork this repo and edit the files in the **src** directory. Then, you can send your PR.

To deploy gb-asm-tutorial locally:

1. Install [Rust](https://www.rust-lang.org/tools/install) and [mdBook](https://github.com/rust-lang/mdBook#readme).
  mdBook powers the book itself, Rust is used for some custom plugins.
  ```
  $ cargo install mdbook
  ```
2. Within a terminal pointed at the directory `book.toml` is in, run mdBook (`mdbook build` / `mdbook watch` / `mdbook serve`).
3. The HTML files are in `book/custom/`.


## License

Different parts of gb-asm-tutorial are subject to different licenses:

- All the code contained within the tutorial itself is licensed under <a rel="license" href="http://creativecommons.org/publicdomain/zero/1.0/">CC0</a>. *To the extent possible under law, all copyright and related or neighboring rights to code presented within GB ASM Tutorial have been waived. This work is published from France.*
- The contents (prose, images, etc.) of this tutorial are licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
- Code used to display and format the site is licensed under the [MIT License](https://github.com/gbdev/gb-asm-tutorial/blob/master/LICENSE) unless otherwise specified.
- The code related to the i18n support is originally from Google's [Comprehensive Rust](https://github.com/google/comprehensive-rust) and is released under the [Apache License 2.0](https://github.com/gbdev/gb-asm-tutorial/blob/master/i18n-helpers/LICENSE).

