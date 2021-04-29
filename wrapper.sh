#!/bin/bash

set +e

echo
echo "  'Nightly Merge Action' is using the following input:"
echo "    - allow_ff = $INPUT_ALLOW_FF"
echo "    - allow_git_lfs = $INPUT_GIT_LFS"
echo "    - ff_only = $INPUT_FF_ONLY"
echo "    - user_name = $INPUT_USER_NAME"
echo "    - user_email = $INPUT_USER_EMAIL"
echo "    - push_token = $INPUT_PUSH_TOKEN = ${!INPUT_PUSH_TOKEN}"
echo "    - dev_branch_pattern = '$INPUT_DEV_BRANCH_PATTERN'"
echo

export INPUT_STABLE_BRANCH=${GITHUB_REF##*/}

if [[ -z "${!INPUT_PUSH_TOKEN}" ]]; then
  echo "Set the ${INPUT_PUSH_TOKEN} env variable."
  exit 1
fi

FF_MODE="--no-ff"
if [[ "$INPUT_ALLOW_FF" == "true" ]]; then
  FF_MODE="--ff"
  if [[ "$INPUT_FF_ONLY" == "true" ]]; then
    FF_MODE="--ff-only"
  fi
fi

git remote set-url origin https://x-access-token:${!INPUT_PUSH_TOKEN}@github.com/$GITHUB_REPOSITORY.git
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

echo "Start search branches"
for branch in $(git branch -r --list $INPUT_DEV_BRANCH_PATTERN | cut -d/ -f2-); do
  echo "Current branch: $branch"
	if [[ "$branch" > "$INPUT_STABLE_BRANCH" ]]; then
		echo "Start update $branch"
		export INPUT_DEVELOPMENT_BRANCH=$branch
		echo "Merge $INPUT_STABLE_BRANCH to $INPUT_DEVELOPMENT_BRANCH"
		../../entrypoint.sh
		RESULT=$?
		if [[ $RESULT == 0 ]]; then
		  export MERGED_LIST=$INPUT_DEVELOPMENT_BRANCH:$MERGED_LIST
		else
		  export CONFLICT_LIST=$INPUT_DEVELOPMENT_BRANCH:$CONFLICT_LIST
		fi
	fi
done;

set -e
if [ ! -z ${$MERGED_LIST##*( )} ];
then
  echo "MERGED: $MERGED_LIST"
fi

if [ ! -z ${CONFLICT_LIST##*( )} ]; then
	echo "FAIL: $CONFLICT_LIST"
	exit 1
fi