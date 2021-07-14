#!/bin/bash

set +e

echo
echo "  'Start with next settings:"
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
  echo "FAIL! Please, set the ${INPUT_PUSH_TOKEN} env variable."
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

echo "#1. Try find next release branch"
for branch in $(git branch -r | grep $INPUT_DEV_BRANCH_PATTERN | sort | cut -d/ -f2-); do
	if [[ "$branch" > "$INPUT_STABLE_BRANCH" ]]; then

		echo "#2. Next release branch = $branch"
		export INPUT_DEVELOPMENT_BRANCH=$branch
		echo "#3. Try merge $INPUT_STABLE_BRANCH to $INPUT_DEVELOPMENT_BRANCH"
		../../entrypoint.sh
		RESULT=$?

		if [[ $RESULT == 0 ]]; then
		  echo "#4. SUCCESS! MERGED $INPUT_STABLE_BRANCH to $INPUT_DEVELOPMENT_BRANCH"
		else
		  echo "#4. FAIL! MERGED $INPUT_STABLE_BRANCH to $INPUT_DEVELOPMENT_BRANCH"
		  exit 1
		fi

		break
	fi
done;
