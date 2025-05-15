use std::{
    collections::{hash_map::Entry, HashMap},
    path::{Path, PathBuf},
};

use anyhow::{anyhow, Context};
use git2::{Blob, Oid, Repository};

#[derive(Default)]
pub struct Repos(HashMap<PathBuf, Repository>);

impl Repos {
    pub fn open(&mut self, path: PathBuf) -> mdbook::errors::Result<&Repository> {
        match self.0.entry(path) {
            Entry::Occupied(occupied_entry) => Ok(occupied_entry.into_mut()),
            Entry::Vacant(vacant_entry) => {
                let repo = Repository::open(vacant_entry.key())?;
                Ok(vacant_entry.insert(repo))
            }
        }
    }
}

pub fn find_commit_by_msg(repo: &Repository, msg: &str) -> mdbook::errors::Result<Oid> {
    let head = repo.head().context("Failed to look up repo HEAD")?;
    let mut commit = head
        .peel_to_commit()
        .context("Failed to get the commit pointed to by HEAD")?;
    while !commit
        .message()
        .ok_or(anyhow!("Non-UTF-8 commit message!?"))?
        .strip_prefix(msg)
        .is_some_and(|rest| rest.is_empty() || rest.starts_with('\n'))
    {
        commit = commit
            .parent(0)
            .context("Failed to find a commit with specified message")?;
    }
    Ok(commit.id())
}

pub fn get_file<'repos>(
    repos: &'repos Repos,
    (repo_path, commit_id): &(PathBuf, Oid),
    path: &Path,
) -> mdbook::errors::Result<Blob<'repos>> {
    let repo = &repos.0[repo_path];
    let commit = repo.find_commit(*commit_id).unwrap();
    let tree = commit
        .tree()
        .context("Unable to obtain the commit's tree")?;
    let entry = tree
        .get_path(path)
        .context("Unable to find the specified file")?;
    let object = entry
        .to_object(repo)
        .context("Unable to obtain the file's object in the repo")?;
    object
        .peel_to_blob()
        .context("The specified path is not a file")
}
