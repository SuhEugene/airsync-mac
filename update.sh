#!/bin/bash

# Save current branch name
CURRENT_BRANCH=$(git branch --show-current)

# Check if there are uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "You have uncommitted changes."
    exit 1
fi

git fetch origin

if git merge-base --is-ancestor origin/main HEAD; then
    echo "Already up to date"
    exit 0
fi

# Attempt to pull with rebase
echo "Pulling origin/main with rebase..."
if ! git pull --rebase origin main; then
    echo "Merge conflict"
    git rebase --abort
    exit 1
fi

# Check if there were any changes
if [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ]; then
    echo "Already up to date"
    exit 0
fi

# Ask user about building
echo "New changes were pulled. Do you want to build a new version? (y/N)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    ./build.sh
else
    echo "Aborting"
    exit 1
fi

echo "Done!"
