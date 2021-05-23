/*
 * This Source Code Form is subject to the
 * terms of the Mozilla Public License, v.
 * 2.0. If a copy of the MPL was not
 * distributed with this file, You can
 * obtain one at
 * http://mozilla.org/MPL/2.0/.
 */

use anyhow::Context;
use lazy_static::lazy_static;
use mdbook::book::BookItem;
use mdbook::errors::{Error, Result};
use mdbook::renderer::{HtmlHandlebars, RenderContext, Renderer};
use regex::Regex;
use std::fs::{self, File};
use std::io::{self, Write};
use std::path::PathBuf;
use termcolor::{Color, ColorChoice, ColorSpec, StandardStream, WriteColor};

fn main() -> Result<()> {
    let mut stdin = io::stdin();
    let ctx = RenderContext::from_json(&mut stdin).unwrap();

    let renderer = GbAsmTut;

    if ctx.version != mdbook::MDBOOK_VERSION {
        // We should probably use the `semver` crate to check compatibility
        // here...
        let mut stderr = StandardStream::stderr(ColorChoice::Auto);
        stderr
            .set_color(ColorSpec::new().set_fg(Some(Color::Yellow)).set_bold(true))
            .unwrap();
        write!(&mut stderr, "warning:").unwrap();
        stderr.reset().unwrap();
        eprintln!(
            " The {} renderer was built against version {} of mdbook, \
             but we're being called from version {}",
            renderer.name(),
            mdbook::MDBOOK_VERSION,
            ctx.version
        );
    }

    renderer.render(&ctx)
}

struct GbAsmTut;

impl Renderer for GbAsmTut {
    fn name(&self) -> &'static str {
        "gb-asm-tutorial"
    }

    fn render(&self, ctx: &RenderContext) -> Result<()> {
        // First, render things using the HTML renderer
        let renderer = HtmlHandlebars;
        renderer.render(ctx)?;

        // Now, post-process the pages in-place to inject the boxes
        for (i, item) in ctx.book.iter().enumerate() {
            match item {
                BookItem::Chapter(chapter) if !chapter.is_draft_chapter() => {
                    let mut path = ctx.destination.join(chapter.path.as_ref().unwrap());
                    path.set_extension("html");
                    render(&mut path, &chapter.name, i)
                        .context(format!("Failed to render {}", &chapter.name))?;
                }

                _ => (),
            }
        }
        // Post-process the print page as well
        render(
            &mut ctx.destination.join("print.html"),
            "<print>",
            usize::MAX,
        )
        .context("Failed to render print page")?;

        // Take the "ANCHOR" lines out of `hello_world.asm`
        let path = ctx.destination.join("assets").join("hello-world.asm");
        let hello_world =
            fs::read_to_string(&path).context(format!("Failed to read {}", path.display()))?;
        let mut output =
            File::create(&path).context(format!("Failed to re-create {}", path.display()))?;
        for line in hello_world.lines() {
            if !line.starts_with("; ANCHOR") {
                writeln!(output, "{}", line)?;
            }
        }

        Ok(())
    }
}

#[derive(Debug)]
enum BoxType {
    Plain,
    Decorated,
}

fn render(path: &mut PathBuf, name: &str, index: usize) -> Result<()> {
    // Since we are about to edit the file in-place, we must buffer it into memory
    let html = fs::read_to_string(&path)?;
    // Open the output file, and possibly the output "index.html" file
    let mut output = File::create(&path)?;
    // The index is generated from the first chapter
    let index_file = if index == 0 {
        path.set_file_name("index.html");
        Some(File::create(&path).context(format!("Failed to create {}", path.display()))?)
    } else {
        None
    };
    macro_rules! output {
        ($string:expr) => {
            output
                .write_all($string.as_bytes())
                .context("Failed to write to output file")?;
            index_file
                .as_ref()
                .map(|mut f| f.write_all($string.as_bytes()))
                .transpose()
                .context(format!("Failed to write to index file"))?;
        };
    }

    let mut cur_box = None;
    let mut in_console = false; // Are we in a "console" code block?
    for (i, mut line) in html.lines().enumerate() {
        let line_no = i + 1;
        lazy_static! {
            static ref CONSOLE_CODE_RE: Regex =
                Regex::new(r#"^<pre><code class="(?:\S*\s+)*language-console(?:\s+\S*)*">"#)
                    .unwrap();
        }

        // Yes, this relies on how the HTML renderer outputs paragraphs, i.e.
        // that tags are flush with the content.
        // Yes, this sucks, and yes, I hate it.
        // If you have a better idea, please tell us! x_x

        if let Some(line) = line.strip_prefix("<p>:::") {
            if let Some(line) = line.strip_suffix("</p>") {
                let line = line.trim();

                if let Some(box_type) = line.split_whitespace().next() {
                    // This is a box start marker
                    if cur_box.is_some() {
                        return Err(Error::msg(format!(
                            "{}:{}: Attempting to open box inside of one",
                            path.display(),
                            line_no
                        )));
                    }

                    let (box_type_name, decoration) = match box_type.find(':') {
                        Some(n) => (&box_type[..n], Some(&box_type[n + 1..])),
                        None => (box_type, None),
                    };

                    let box_type_name = if ["tip", "warning", "danger"].contains(&box_type_name) {
                        box_type_name
                    } else {
                        let mut stderr = StandardStream::stderr(ColorChoice::Auto);
                        stderr
                            .set_color(ColorSpec::new().set_fg(Some(Color::Yellow)).set_bold(true))
                            .unwrap();
                        write!(&mut stderr, "warning").unwrap();
                        stderr.reset().unwrap();
                        eprintln!(
                            " ({}): unknown box type \"{}\", defaulting to \"tip\"",
                            name, box_type_name
                        );
                        "tip"
                    };
                    output!(format!(
                        "<div class=\"box {}{}\">\n",
                        box_type_name,
                        decoration.map_or("", |_| " decorated")
                    ));

                    cur_box = if let Some(decoration) = decoration {
                        output!(format!("<div><p>{}</p></div>\n<div>\n", decoration));
                        Some(BoxType::Decorated)
                    } else {
                        Some(BoxType::Plain)
                    };

                    let title = &line[box_type.len()..].trim_start();
                    if !title.is_empty() {
                        output!(format!("<p class=\"box-title\">{}</p>", title));
                    }
                } else {
                    // This is a box ending marker
                    match cur_box {
                        None => {
                            return Err(Error::msg(format!(
                                "{}:{}: Attempting to close box outside of one",
                                path.display(),
                                line_no
                            )))
                        }
                        Some(BoxType::Decorated) => {
                            output!("</div>\n"); // Close the `box-inner
                        }
                        Some(BoxType::Plain) => (),
                    }
                    cur_box = None;

                    output!("</div>\n");
                }

                // Prevent normal output
                continue;
            } else {
                let mut stderr = StandardStream::stderr(ColorChoice::Auto);
                stderr
                    .set_color(ColorSpec::new().set_fg(Some(Color::Yellow)).set_bold(true))
                    .unwrap();
                write!(&mut stderr, "warning").unwrap();
                stderr.reset().unwrap();
                eprintln!(" ({}): ignoring \":::{}\"; box start/end tags must be alone in their paragraph", name, line);
            }
        } else if let Some(match_info) = CONSOLE_CODE_RE.find(line) {
            output!("<pre><code>"); // Disable the highlighting
            in_console = true;
            debug_assert_eq!(match_info.start(), 0);
            line = &line[match_info.end()..]; // Output the rest
        } else if line == "</code></pre>" {
            in_console = false;
        }

        match line.strip_prefix("$ ") {
            Some(line) if in_console => {
                // `highlight.js` assigned the "meta" class when highlighting `$` in the `console`
                // language, so manually apply that class to keep the styling
                output!(
                    "<span class=\"console-line hljs-meta\"></span><span class=\"language-bash\">"
                );
                output!(line);
                output!("</span>");
            }
            _ => {
                output!(line);
            }
        }
        output!("\n");
    }

    if cur_box.is_some() {
        return Err(Error::msg(format!("{}: Unclosed box", path.display())));
    }

    Ok(())
}
