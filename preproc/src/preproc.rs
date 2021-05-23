/*
 * This Source Code Form is subject to the
 * terms of the Mozilla Public License, v.
 * 2.0. If a copy of the MPL was not
 * distributed with this file, You can
 * obtain one at
 * http://mozilla.org/MPL/2.0/.
 */

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

        let res = Ok(());
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
                    // match Self::process_content(&content) {
                    //     Ok(content) => ch.content = content,
                    //     Err(err) => res = Err(err),
                    // }
                }
            }
        });

        res.map(|_| book)
    }
}
/*
impl GbAsmTut {
    fn process_content(content: &str) -> Result<String, Error> {
        let mut buf = String::with_capacity(content.len());
        let mut state = None;

        let mut serialize = |events: &[_]| -> Result<_, Error> {
            let state = &mut state;
            *state = Some(
                pulldown_cmark_to_cmark::cmark(events.iter(), &mut buf, state.clone())
                    .map_err(|err| Error::from(err).context("Markdown serialization failed"))?,
            );
            Ok(())
        };

        let mut events = Parser::new(&content);
        while let Some(event) = events.next() {
            match event {
                Event::Start(Tag::CodeBlock(CodeBlockKind::Fenced(lang)))
                    if lang.starts_with("linenos__") =>
                {
                    let start = Event::Start(Tag::CodeBlock(CodeBlockKind::Fenced(
                        lang.strip_prefix("linenos__").unwrap().to_string().into(),
                    )));
                    let code = events.next().expect("Code blocks must at least be closed");

                    if matches!(code, Event::End(_)) {
                        serialize(&[start, code])?;
                    } else if let Event::Text(code) = code {
                        let end = events.next().expect("Code blocks must be closed");
                        if !matches!(end, Event::End(_)) {
                            return Err(Error::msg(format!(
                                "Unexpected {:?} instead of code closing tag",
                                end
                            )));
                        }

                        eprintln!("{:?}", code);
                        let line_nos: String = code
                            .lines()
                            .enumerate()
                            .map(|(n, _)| format!("{}\n", n))
                            .collect();
                        serialize(&[
                            Event::Start(Tag::CodeBlock(CodeBlockKind::Fenced("linenos".into()))),
                            Event::Text(line_nos.into()),
                            Event::End(Tag::CodeBlock(CodeBlockKind::Fenced("linenos".into()))),
                            start,
                            Event::Text(code),
                            end,
                        ])?;
                    } else {
                        return Err(Error::msg(format!("Unexpected {:?} within code tag", code)));
                    }
                }

                _ => serialize(&[event])?,
            }
        }

        Ok(buf)
    }
}
*/
