#!/bin/bash
set -euxo pipefail
 

# Count unpushed commits
count=$(git rev-list --count @{u}..HEAD)

if [ "$count" -le 1 ]; then
  echo "Nothing to squash or only one commit."
  exit 0
fi

# Generate rebase todo list: first pick, rest squash
# Get the SHAs and messages of the commits to squash
commits=$(git rev-list --reverse HEAD~$((count - 1))..HEAD)

# Create the todo file for the interactive rebase
# First commit: pick
# rest: squash
rebase_todo=""

first=1
for sha in $commits; do
  if [ $first -eq 1 ]; then
    rebase_todo+="pick $sha\n"
    first=0
  else
    rebase_todo+="squash $sha\n"
  fi
done

# Run the interactive rebase with the todo list piped in
echo -e "$rebase_todo" | GIT_SEQUENCE_EDITOR="cat" git rebase -i --autosquash --autostash HEAD~$count

# Use the most recent commit message only, discard others
# This triggers after rebase stops for commit message editing
git commit --amend -m "$(git log -1 --pretty=%B)"
