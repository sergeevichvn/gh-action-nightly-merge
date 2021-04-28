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

set +o xtrace
echo
echo "  'Nightly Merge Action' is trying to merge the '$INPUT_STABLE_BRANCH' branch ($(git log -1 --pretty=%H $INPUT_STABLE_BRANCH))"
echo "  into the '$INPUT_DEVELOPMENT_BRANCH' branch ($(git log -1 --pretty=%H $INPUT_DEVELOPMENT_BRANCH))"
echo
set -o xtrace

# Do the merge
git merge $FF_MODE --no-edit $INPUT_STABLE_BRANCH

# Pull lfs if enabled
if [[ $INPUT_GIT_LFS == "true" ]]; then
  git lfs pull
fi

# Push the branch
git push origin $INPUT_DEVELOPMENT_BRANCH
