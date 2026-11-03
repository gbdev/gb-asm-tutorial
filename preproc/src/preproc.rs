/*
 * This Source Code Form is subject to the
 * terms of the Mozilla Public License, v.
 * 2.0. If a copy of the MPL was not
 * distributed with this file, You can
 * obtain one at
 * http://mozilla.org/MPL/2.0/.
 */

use crate::git::Commit;
use crate::links;
use anyhow::Result;
use mdbook_preprocessor::{
    book::{Book, BookItem},
    errors::Error,
    Preprocessor, PreprocessorContext,
};

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

    fn supports_renderer(&self, renderer: &str) -> Result<bool, anyhow::Error> {
        Ok(renderer != "not-supported")
    }

    fn run(&self, ctx: &PreprocessorContext, mut book: Book) -> Result<Book, Error> {
        let src_dir = ctx.root.join(&ctx.config.book.src);

        let commit = if ctx.root.join(".git").exists() {
            Some(Commit::rev_parse("HEAD")?)
        } else {
            None
        };

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

                    ch.content = links::replace_all(&ch.content, base);
                    if let Err(err) = self.process_admonitions(ch) {
                        res = Err(err);
                    }

                    if ch.name == "Home" {
                        if let Some(ref commit) = commit {
                            ch.content.push_str(&format!(
                                "\n\n\n <small>This document version was produced from git commit [`{}`](https://github.com/gbdev/gb-asm-tutorial/tree/{}) ({}).</small>\n",
                                commit.short_hash(),
                                commit.hash(),
                                commit.timestamp(),
                            ));
                        }
                    }
                }
            }
        });

        res.map(|_| book)
    }
}
