# GB ASM tutorial (v2)

Re-doing [GB ASM Tutorial](https://github.com/ISSOtm/gb-asm-tutorial-old), and this time, until the end.

## Contributing 

Contributing is really easy, fork this repo and edit the files in the **src** directory. Then, you can send your PR.

To deploy gb-asm-tutorial locally:

1. Install [Rust](https://www.rust-lang.org/tools/install) and [mdBook](https://github.com/rust-lang/mdBook#readme).
  mdBook powers the book itself, Rust is used for some custom plugins.
```
$ cargo install mdbook
$ cargo install --path i18n-helpers
```
2. Within a terminal pointed at the directory `book.toml` is in, run mdBook (`mdbook build` / `mdbook watch` / `mdbook serve`).
3. The HTML files are in `book/custom/`.

  ⚠️ `book/html/` contains only partially processed files.
  This folder is what gets served when running `mdbook serve`, so you may see some custom markup missing if using that.
  As a workaround, you can manually open the files in the `book/custom/` folder in your browser, they just won't auto-refresh on changes.

To add a translation or contribute on an existing one, please see [TRANSLATING](TRANSLATING.md).

### Syntax highlighting

Syntax highlighting is provided within the browser, courtesy of [`highlight.js`](https://github.com/highlightjs/highlight.js).
[RGBASM syntax](https://rgbds.gbdev.io/docs/rgbasm.5) is highlighted via [a plugin](https://github.com/gbdev/highlightjs-rgbasm), but this requires a custom build of `highlight.js`.

Steps:

1. [Clone](https://docs.github.com/en/github/getting-started-with-github/getting-started-with-git/about-remote-repositories) `highlight.js` anywhere, and go into that directory.

   You will probably want to target a specific version by checking out its tag.
2. Run `npm install` to install its dependencies.
3. Within the `extras/` directory, clone `highlightjs-rgbasm`; ensure the directory is called `rgbasm`, otherwise the build tool won't pick it up.
4. You can work on and make modifications to `highlightjs-rgbasm`!
5. To make the custom build of `highlight.js`, within the `highlight.js` directory, run `node tools/build.js -t browser <languages>...`, with `<languages>...` being the list of languages to enable support for.
  The languages identifiers are the same that you would use for highlighting (` ```rgbasm `, for example).
6. Copy `build/highlight.min.js` as `theme/highlight.js` in Pan Docs' source.
  Alternatively, for debugging, you can use `build/highlight.js` for a non-minified version, but please don't commit that.

  ⚠️ `mdbook watch` and `mdbook serve` do *not* watch for changes to files in the `theme/` directory, you must trigger the build by either restarting the command, or manually changing one of the watched files.

Example:

```console
$ git clone git@github.com:highlightjs/highlight.js.git
$ cd highlight.js
$ git checkout 10.7.2
$ npm install
$ git clone git@github.com:gbdev/highlightjs-rgbasm.git extras/rgbasm
$ node tools/build.js -t browser rgbasm shell makefile
$ cp build/highlight.min.js ../gb-asm-tutorial/theme/highlight.js
```

## License

Different parts of gb-asm-tutorial are subject to different licenses:

- All the code contained within the tutorial itself is licensed under <a rel="license" href="http://creativecommons.org/publicdomain/zero/1.0/">CC0</a>. *To the extent possible under law, all copyright and related or neighboring rights to code presented within GB ASM Tutorial have been waived. This work is published from France.*
- The contents (prose, images, etc.) of this tutorial are licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
- Code used to display and format the site is licensed under the [MIT License](https://github.com/gbdev/gb-asm-tutorial/blob/master/LICENSE) unless otherwise specified.
- The code related to the i18n support is originally from Google's [Comprehensive Rust](https://github.com/google/comprehensive-rust) and it's released under the [Apache License 2.0](https://github.com/gbdev/gb-asm-tutorial/blob/master/i18n-helpers/LICENSE).

