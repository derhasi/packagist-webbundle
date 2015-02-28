#!/bin/bash

# Environment variables needed
#
# - DOWNSTREAM_REPOSITORY
# - DOWNSTREAM_BRANCH
# - SUBTREE_PREFIX
# - SUBTREE_BRANCH

# Quit immediately if any command fails.
set -e

# Retrieve data from remote repository to build subtree from.
git remote add downstream $DOWNSTREAM_REPOSITORY
git fetch downstream

git checkout -b "downstream" "downstream/$DOWNSTREAM_BRANCH"

# We split the subtree of the downstream in a new branch, so
git subtree split --prefix="$SUBTREE_PREFIX" --branch="$SUBTREE_BRANCH"

#
git push origin "$SUBTREE_BRANCH:$SUBTREE_BRANCH"
