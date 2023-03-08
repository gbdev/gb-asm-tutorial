# Syntax highlighting

Syntax highlighting is provided within the browser, courtesy of [`highlight.js`](https://github.com/highlightjs/highlight.js).
[RGBASM syntax](https://rgbds.gbdev.io/docs/rgbasm.5) is highlighted via [a plugin](https://github.com/gbdev/highlightjs-rgbasm), but this requires a custom build of `highlight.js`.

Here are the steps to generate a new `highlight.js`:

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
