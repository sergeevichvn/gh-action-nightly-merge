#!/bin/bash

set -o xtrace

git fetch origin $INPUT_STABLE_BRANCH
(git checkout $INPUT_STABLE_BRANCH && git pull)||git checkout -b $INPUT_STABLE_BRANCH origin/$INPUT_STABLE_BRANCH

git fetch origin $INPUT_DEVELOPMENT_BRANCH
(git checkout $INPUT_DEVELOPMENT_BRANCH && git pull)||git checkout -b $INPUT_DEVELOPMENT_BRANCH origin/$INPUT_DEVELOPMENT_BRANCH

if git merge-base --is-ancestor $INPUT_STABLE_BRANCH $INPUT_DEVELOPMENT_BRANCH; then
  echo "No merge is necessary"
  exit 0
fi;

# Do the merge
RESULT=$(git merge $FF_MODE --no-edit $INPUT_STABLE_BRANCH)

# Pull lfs if enabled
if [[ $INPUT_GIT_LFS == "true" ]]; then
  git lfs pull
fi

if [[ $RESULT == *"CONFLICT"* ]]; then
  git reset --hard
  echo "exit1-test"
  exit 1
else
  # Push the branch
  git push origin $INPUT_DEVELOPMENT_BRANCH
  exit 0
fi
