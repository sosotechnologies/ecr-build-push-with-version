#!/bin/bash

# Check if VERSION file exists
if [ ! -f VERSION-GPU-TASK ]; then
  echo "2.2.19" > VERSION-GPU-TASK
fi

current_version=$(cat VERSION-GPU-TASK)

IFS='.' read -r -a version_parts <<< "$current_version"
version_parts[2]=$((version_parts[2] + 1))
new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

# Write the new version back to the VERSION file
echo $new_version > VERSION-GPU-TASK

# sed -i "s/value: \"[0-9.]*\"/value: \"$new_version\"/g" build-push-to-gh/worldworkflow.yaml

echo $new_version