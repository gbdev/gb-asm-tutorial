/*
 * This Source Code Form is subject to the
 * terms of the Mozilla Public License, v.
 * 2.0. If a copy of the MPL was not
 * distributed with this file, You can
 * obtain one at
 * http://mozilla.org/MPL/2.0/.
 */

use anyhow::Result;
use lazy_static::lazy_static;
use mdbook::errors::Error;
use regex::{CaptureMatches, Captures, Regex};
use std::fs::File;
use std::io::{BufRead, BufReader, Write};
use std::path::Path;
use std::str;
use termcolor::{Color, ColorChoice, ColorSpec, StandardStream, WriteColor};

pub fn replace_all<P1: AsRef<Path>>(s: &str, path: P1) -> String {
    // When replacing one thing in a string by something with a different length,
    // the indices after that will not correspond,
    // we therefore have to store the difference to correct this
    let path = path.as_ref();
    let mut previous_end_index = 0;
    let mut replaced = String::new();

    for link in find_links(s) {
        replaced.push_str(&s[previous_end_index..link.start_index]);

        match link.render_with_path(&path) {
            Ok(new_content) => {
                replaced.push_str(&new_content);
                previous_end_index = link.end_index;
            }
            Err(e) => {
                let mut stderr = StandardStream::stderr(ColorChoice::Auto);
                stderr
                    .set_color(ColorSpec::new().set_fg(Some(Color::Red)).set_bold(true))
                    .unwrap();
                write!(&mut stderr, "error:").unwrap();
                stderr.reset().unwrap();

                eprintln!(" Error updating \"{}\", {}", link.link_text, e);
                for cause in e.chain().skip(1) {
                    let mut stderr = StandardStream::stderr(ColorChoice::Auto);
                    stderr
                        .set_color(ColorSpec::new().set_fg(Some(Color::Yellow)).set_bold(true))
                        .unwrap();
                    write!(&mut stderr, "warning:").unwrap();
                    stderr.reset().unwrap();

                    eprintln!(" Caused By: {}", cause);
                }

                // This should make sure we include the raw `{{# ... }}` snippet
                // in the page content if there are any errors.
                previous_end_index = link.start_index;
            }
        }
    }

    replaced.push_str(&s[previous_end_index..]);
    replaced
}

#[derive(PartialEq, Debug, Clone)]
struct Link<'a> {
    start_index: usize,
    end_index: usize,
    link_text: &'a str,

    regex: &'a str,
    path: &'a str,
}

impl<'a> Link<'a> {
    fn from_capture(capture: Captures<'a>) -> Link<'a> {
        let mat = capture.get(0).unwrap();
        Link {
            start_index: mat.start(),
            end_index: mat.end(),
            link_text: mat.as_str(),

            regex: capture.get(1).unwrap().as_str(),
            path: capture.get(2).unwrap().as_str(),
        }
    }

    fn render_with_path<P: AsRef<Path>>(&self, base: P) -> Result<String> {
        lazy_static! {
            static ref ANCHOR_START: Regex = Regex::new(r"ANCHOR:\s*([\w_-]+)").unwrap();
            static ref ANCHOR_END: Regex = Regex::new(r"ANCHOR_END:\s*([\w_-]+)").unwrap();
        }

        let base = base.as_ref();
        let regex = Regex::new(&self.regex)?;
        let mut parts = self.path.split(':');
        let path = parts.next().unwrap();
        let (begin, end, section) = parse_parts(parts)?;
        let mut section: Option<(_, &Regex)> = if let Some(section) = section {
            Some((section, &ANCHOR_START))
        } else {
            None
        };

        let mut input = BufReader::new(File::open(base.join(path))?);
        let mut line = String::new();
        let mut line_no = 0;
        let mut try_matching = section.is_none() && begin.is_none();

        loop {
            line.clear();
            let len = input.read_line(&mut line)?;
            if len == 0 {
                break;
            }

            if !ANCHOR_START.is_match(&line) && !ANCHOR_END.is_match(&line) {
                line_no += 1;
            }
            if begin == Some(line_no) {
                try_matching = true;
            }

            if try_matching && regex.is_match(&line) {
                return Ok(line_no.to_string());
            }

            if let Some(sect_regex) = section.as_mut() {
                // Check if this line begins or ends (depending on the regex) the section
                match sect_regex.1.captures(&line) {
                    Some(caps) if &caps[1] == sect_regex.0 => {
                        if !try_matching {
                            // Section start
                            sect_regex.1 = &ANCHOR_END;
                            try_matching = true;
                            line_no = 0;
                        } else {
                            // Section end
                            break;
                        }
                    }
                    _ => (),
                }
            }
            if end == Some(line_no) {
                debug_assert!(try_matching); // This should have been checked earlier
                break;
            }
        }

        Err(Error::msg(match (try_matching, begin, section) {
            // Failed to match, simply enough
            (true, _, _) => format!("Could not match \"{}\" in \"{}\"", &self.regex, &self.path),
            // Never begun matching?
            (false, Some(begin), None) => {
                format!("{} is only {} lines long, not {}", path, line_no, begin)
            }
            (false, None, Some((section, _))) => {
                format!("{} doesn't contain section \"{}\"", path, section)
            }
            // Impossible, only reason not to be matching is for either start condition to exist
            (false, None, None) => unreachable!(),
            // Impossible, the conditions are mutually exclusive
            (false, Some(_), Some(_)) => unreachable!(),
        }))
    }
}

fn parse_parts<'a, I: Iterator<Item = &'a str>>(
    mut parts: I,
) -> Result<(Option<u64>, Option<u64>, Option<&'a str>)> {
    if let Some(first) = parts.next() {
        if let Some(second) = parts.next() {
            if parts.next().is_some() {
                return Err(Error::msg("Too many parts, expected at most 2"));
            }

            let parse = |string: &str| -> Result<_> {
                Ok(if string.is_empty() {
                    None
                } else {
                    Some(string.parse()?)
                })
            };
            let (begin, end) = (parse(first)?, parse(second)?);
            match (begin, end) {
                (Some(begin), Some(end)) if begin > end => Err(Error::msg(format!(
                    "Asked to search from line {} to {}...",
                    begin, end
                ))),
                _ => Ok((begin, end, None)),
            }
        } else {
            Ok((None, None, Some(first)))
        }
    } else {
        Ok((None, None, None))
    }
}

struct LinkIter<'a>(CaptureMatches<'a, 'a>);

impl<'a> Iterator for LinkIter<'a> {
    type Item = Link<'a>;
    fn next(&mut self) -> Option<Link<'a>> {
        self.0.next().map(Link::from_capture)
    }
}

fn find_links(contents: &str) -> LinkIter<'_> {
    // lazily compute the following regex:
    // r#"\{\{#line_no_of\s*"([^"]+)"\s+([^}]+)\}\}"#)?;
    lazy_static! {
        static ref RE: Regex = Regex::new(
            r#"(?x)         # insignificant whitespace mode
            \{\{\s*         # link opening parens and whitespace
            \#line_no_of    # link type
            \s+             # separating whitespace
            "([^"]+)"       # regex being searched for
            \s+             # separating whitespace
            ([^}]+)         # path to search
            \}\}            # link closing parens"#
        )
        .unwrap();
    }
    LinkIter(RE.captures_iter(contents))
}
