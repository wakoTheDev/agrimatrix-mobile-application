#!/bin/bash

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$latest_tag" ]; then
    # If no tags exist, get all commits
    git log --pretty=format:"* %s" > CHANGELOG.md
else
    # Get commits since latest tag
    git log ${latest_tag}..HEAD --pretty=format:"* %s" > CHANGELOG.md
fi
