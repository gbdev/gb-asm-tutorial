/*
 * This Source Code Form is subject to the
 * terms of the Mozilla Public License, v.
 * 2.0. If a copy of the MPL was not
 * distributed with this file, You can
 * obtain one at
 * http://mozilla.org/MPL/2.0/.
 */

use crate::git::Repos;
use crate::links;
use anyhow::Result;
use mdbook::book::{Book, BookItem};
use mdbook::errors::Error;
use mdbook::preprocess::{Preprocessor, PreprocessorContext};

pub struct GbAsmTut;

impl GbAsmTut {
    pub fn new() -> GbAsmTut {
        GbAsmTut
    }
}

impl Preprocessor for GbAsmTut {
    fn name(&self) -> &str {
        "gb-asm-tutorial"
    }

    fn supports_renderer(&self, renderer: &str) -> bool {
        renderer != "not-supported"
    }

    fn run(&self, ctx: &PreprocessorContext, mut book: Book) -> Result<Book, Error> {
        let src_dir = ctx.root.join(&ctx.config.book.src);
        let mut repos = Repos::default();

        let mut res = Ok(());
        book.for_each_mut(|section: &mut BookItem| {
            if res.is_err() {
                return;
            }

            if let BookItem::Chapter(ref mut ch) = *section {
                if let Some(ref chapter_path) = ch.path {
                    let base = chapter_path
                        .parent()
                        .map(|dir| src_dir.join(dir))
                        .expect("All book items have a parent");

                    ch.content = links::replace_all(&ch.content, &ch.name, base, &mut repos);
                    if let Err(err) = self.process_admonitions(ch) {
                        res = Err(err);
                    }
                }
            }
        });

        res.map(|_| book)
    }
}
