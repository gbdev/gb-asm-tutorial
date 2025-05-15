/*
 * This Source Code Form is subject to the
 * terms of the Mozilla Public License, v.
 * 2.0. If a copy of the MPL was not
 * distributed with this file, You can
 * obtain one at
 * http://mozilla.org/MPL/2.0/.
 */

use anyhow::{anyhow, bail, Context, Result};
use git2::Oid;
use lazy_static::lazy_static;
use mdbook::errors::Error;
use regex::{CaptureMatches, Captures, Regex};
use std::fs::File;
use std::io::{BufRead, BufReader, Write};
use std::ops::Deref;
use std::path::{Path, PathBuf};
use std::str;
use termcolor::{Color, ColorChoice, ColorSpec, StandardStream, WriteColor};

use crate::git::Repos;

pub fn replace_all<P1: AsRef<Path>>(s: &str, name: &str, path: P1, repos: &mut Repos) -> String {
    // When replacing one thing in a string by something with a different length,
    // the indices after that will not correspond,
    // we therefore have to store the difference to correct this
    let path = path.as_ref();
    let mut previous_end_index = 0;
    let mut replaced = String::new();

    let mut commit = None;

    for link in find_links(s) {
        replaced.push_str(&s[previous_end_index..link.start_index]);

        match link.render_with_path(path, repos, &mut commit) {
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

                eprintln!(" [{name}] Error rendering \"{}\":", link.link_text);
                eprintln!("       {e}");
                for cause in e.chain().skip(1) {
                    eprintln!("    ...caused by: {}", cause);
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
struct Link<'text> {
    start_index: usize,
    end_index: usize,
    link_text: &'text str,
    kind: LinkKind<'text>,
}
#[derive(Debug, Clone, PartialEq)]
enum LinkKind<'text> {
    LineNoOf { regex: &'text str, path: &'text str },
    UseCommit { path: &'text str, msg: &'text str },
    IncludeGit { path: &'text str },
}

impl<'text> Link<'text> {
    fn from_capture(capture: Captures<'text>) -> Link<'text> {
        let mat = capture.get(0).unwrap();
        Link {
            start_index: mat.start(),
            end_index: mat.end(),
            link_text: mat.as_str(),

            kind: if let Some(regex) = capture.get(1) {
                LinkKind::LineNoOf {
                    regex: regex.as_str(),
                    path: capture.get(2).unwrap().as_str(),
                }
            } else if let Some(path) = capture.get(3) {
                LinkKind::UseCommit {
                    path: path.as_str(),
                    msg: capture.get(4).unwrap().as_str(),
                }
            } else {
                LinkKind::IncludeGit {
                    path: capture.get(5).unwrap().as_str(),
                }
            },
        }
    }

    fn render_with_path<P: AsRef<Path>>(
        &self,
        base: P,
        repos: &mut Repos,
        commit: &mut Option<(PathBuf, Oid)>,
    ) -> Result<String> {
        match self.kind {
            LinkKind::LineNoOf { regex, path } => {
                render_line_no_of(regex, path, base.as_ref(), repos, commit.as_ref())
            }
            LinkKind::UseCommit { path, msg } => {
                let repo_path = base.as_ref().join(path);
                let repo = repos
                    .open(repo_path.clone())
                    .context("Unable to open repository")?;
                commit.replace((repo_path, crate::git::find_commit_by_msg(repo, msg)?));
                Ok(String::new())
            }
            LinkKind::IncludeGit { path } => render_include_git(path, repos, commit.as_ref()),
        }
    }
}

fn render_line_no_of(
    regex: &str,
    path: &str,
    base: &Path,
    repos: &Repos,
    commit: Option<&(PathBuf, Oid)>,
) -> Result<String> {
    let regex = Regex::new(regex).context("Bad regex")?;
    let mut parts = path.split(':');
    let path = parts.next().unwrap();
    let (begin, end, section) = parse_parts(parts)?;

    fn process_lines<R: BufRead>(
        mut input: R,
        regex: Regex,
        path: &str,
        begin: Option<u64>,
        end: Option<u64>,
        section: Option<&str>,
    ) -> Result<String> {
        lazy_static! {
            static ref ANCHOR_START: Regex = Regex::new(r"ANCHOR:\s*([\w_-]+)").unwrap();
            static ref ANCHOR_END: Regex = Regex::new(r"ANCHOR_END:\s*([\w_-]+)").unwrap();
        }

        let mut section = section.map(|section| (section, ANCHOR_START.deref()));

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
            (true, _, _) => format!("Could not match \"{}\" in \"{}\"", &regex, &path),
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

    if let Some(path_in_repo) = path.strip_prefix("@GIT@/") {
        let blob = crate::git::get_file(
            repos,
            commit.ok_or(anyhow!("Please specify `#use_commit` beforehand"))?,
            path_in_repo.as_ref(),
        )?;
        process_lines(blob.content(), regex, path, begin, end, section)
    } else {
        process_lines(
            BufReader::new(File::open(base.join(path))?),
            regex,
            path,
            begin,
            end,
            section,
        )
    }
}

fn render_include_git(
    path: &str,
    repos: &Repos,
    commit: Option<&(PathBuf, Oid)>,
) -> Result<String> {
    let mut parts = path.split(':');
    let path = parts.next().unwrap();
    let (begin, end, section) = parse_parts(parts)?;
    let mut section = section.map(|section| (section, ANCHOR_START.deref()));

    let blob = crate::git::get_file(
        repos,
        commit.ok_or(anyhow!("Please specify `#use_commit` beforehand"))?,
        path.as_ref(),
    )?;
    let mut input = blob.content();

    // FIXME: don't duplicate this with `render_line_no_of`
    lazy_static! {
        static ref ANCHOR_START: Regex = Regex::new(r"ANCHOR:\s*([\w_-]+)").unwrap();
        static ref ANCHOR_END: Regex = Regex::new(r"ANCHOR_END:\s*([\w_-]+)").unwrap();
    }

    let mut line = String::new();
    let mut line_no = 0;
    let mut include = section.is_none() && begin.is_none();
    let mut text = String::new();

    loop {
        line.clear();
        let len = input.read_line(&mut line)?;
        if len == 0 {
            break;
        }

        if !ANCHOR_START.is_match(&line) && !ANCHOR_END.is_match(&line) {
            line_no += 1;
            if begin == Some(line_no) {
                include = true;
            }
            if include {
                text.push_str(&line);
            }
        }

        if let Some(sect_regex) = section.as_mut() {
            // Check if this line begins or ends (depending on the regex) the section
            match sect_regex.1.captures(&line) {
                Some(caps) if &caps[1] == sect_regex.0 => {
                    if !include {
                        // Section start
                        sect_regex.1 = &ANCHOR_END;
                        include = true;
                    } else {
                        // Section end
                        break;
                    }
                }
                _ => (),
            }
        }
        if end == Some(line_no) {
            debug_assert!(include); // This should have been checked earlier
            break;
        }
    }
    text.truncate(text.trim_end().len());

    match (include, begin, section) {
        // Failed to match, simply enough
        (true, _, _) => Ok(text),
        // Never begun matching?
        (false, Some(begin), None) => {
            bail!("{path} is only {line_no} lines long, not {begin}")
        }
        (false, None, Some((section, _))) => {
            bail!("{path} doesn't contain section \"{section}\"")
        }
        // Impossible, only reason not to be matching is for either start condition to exist
        (false, None, None) => unreachable!(),
        // Impossible, the conditions are mutually exclusive
        (false, Some(_), Some(_)) => unreachable!(),
    }
}

fn parse_parts<'text, I: Iterator<Item = &'text str>>(
    mut parts: I,
) -> Result<(Option<u64>, Option<u64>, Option<&'text str>)> {
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

struct LinkIter<'text>(CaptureMatches<'text, 'text>);

impl<'text> Iterator for LinkIter<'text> {
    type Item = Link<'text>;
    fn next(&mut self) -> Option<Link<'text>> {
        self.0.next().map(Link::from_capture)
    }
}

fn find_links(contents: &str) -> LinkIter<'_> {
    lazy_static! {
        static ref RE: Regex = Regex::new(
            r#"(?x)         # insignificant whitespace mode
            \{\{\s*         # link opening parens and whitespace
            (?:
                \#line_no_of    # link type
                \s+             # separating whitespace
                "([^"]*)"       # regex being searched for
                \s+             # separating whitespace
                ([^}]+)         # path to search
            |
                \#use_commit    # link type
                \s+             # separating whitespace
                (\S+)           # path to repo
                @               # separating at-sign
                "([^"]+)"       # commit name
            |
                \#include_git   # link type
                \s+             # separating whitespace
                ([^}]+)         # path to include
            )
            \}\}            # link closing parens"#
        )
        .unwrap();
    }
    LinkIter(RE.captures_iter(contents))
}
