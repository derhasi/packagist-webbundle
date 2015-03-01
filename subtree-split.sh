#!/bin/bash

# Environment variables needed
#
# - DOWNSTREAM_REPOSITORY
# - DOWNSTREAM_BRANCH
# - SUBTREE_PREFIX
# - SUBTREE_BRANCH
# - GH_TOKEN (optional)

# Quit immediately if any command fails.
set -e

# For now we deal with "origin" as upstream repo.
# Make sure that is not set as git:-url as github does not allow to push there.
# Therefore we replace "git:" with "https:".
UPSTREAM_REPOSITORY=$(git config --get remote.origin.url)
UPSTREAM_REPOSITORY=${UPSTREAM_REPOSITORY/#"git:"/"https:"}
if [[ "$GH_TOKEN" != "" ]]
then
  UPSTREAM_REPOSITORY=${UPSTREAM_REPOSITORY/#"https://"/"https://$GH_TOKEN@"}
fi

git remote set-url origin $UPSTREAM_REPOSITORY

# Retrieve data from remote repository to build subtree from.
git remote add downstream $DOWNSTREAM_REPOSITORY
git fetch downstream

git checkout -b "downstream" "downstream/$DOWNSTREAM_BRANCH"

# We split the subtree of the downstream in a new branch, so
git subtree split --prefix="$SUBTREE_PREFIX" --branch="$SUBTREE_BRANCH"

#
git push origin "$SUBTREE_BRANCH:$SUBTREE_BRANCH" > /dev/null 2>&1
