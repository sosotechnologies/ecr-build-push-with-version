#!/bin/bash

# Check if VERSION-TEMP-WORLD file exists
if [ ! -f VERSION-TEMP-WORLD ]; then
  echo "2.2.19" > VERSION-TEMP-WORLD
fi

current_version=$(cat VERSION-TEMP-WORLD)

IFS='.' read -r -a version_parts <<< "$current_version"
version_parts[2]=$((version_parts[2] + 1))
new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

# Write the new version back to the VERSION-TEMP-WORLD file
echo $new_version > VERSION-TEMP-WORLD

sed -i "s/value: \"[0-9.]*\"/value: \"$new_version\"/g" build-push-to-gh/WorkflowTemplate.yaml

echo $new_version