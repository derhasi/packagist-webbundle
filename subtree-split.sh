#!/bin/bash

# Environment variables needed
#
# - UPSTREAM_REPOSITORY
# - UPSTREAM_BRANCH
# - SUBTREE_PREFIX
# - SUBTREE_BRANCH

# Quit immediately if any command fails.
set -e

git remote add upstream $UPSTREAM_REPOSITORY
git fetch upstream

git checkout -b "upstream" "upstream/$UPSTREAM_BRANCH"

# We split the subtree of the upstream in a new branch, so
git subtree split --prefix="$SUBTREE_PREFIX" --branch="$SUBTREE_BRANCH"

#
git push origin "$SUBTREE_BRANCH:$SUBTREE_BRANCH"
