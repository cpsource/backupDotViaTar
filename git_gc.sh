#!/bin/bash

# This script finds every directory with a .git directory in it
# starting from the top-level directory and runs 'git gc' in each of these directories.

# Find all directories with a .git subdirectory
git_directories=$(find . -type d -name ".git")

# Loop through each .git directory and run 'git gc' in its parent directory
for git_dir in $git_directories; do
  # Get the parent directory of the .git directory
  repo_dir=$(dirname "$git_dir")
  
  # Change to the repository directory
  cd "$repo_dir"
  
  # Run git gc
  echo "** Running 'git gc' in $repo_dir"
  git gc
  
  # Change back to the top-level directory
  cd - > /dev/null
done

echo "Completed 'git gc' in all repositories."

