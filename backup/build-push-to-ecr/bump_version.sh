#!/bin/bash

# Check if VERSION file exists
if [ ! -f VERSION ]; then
  echo "2.2.19" > VERSION
fi

current_version=$(cat VERSION)

IFS='.' read -r -a version_parts <<< "$current_version"
version_parts[2]=$((version_parts[2] + 1))
new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

# Write the new version back to the VERSION file
echo $new_version > VERSION

# Update WorkflowTemplate.yaml
sed -i "s/version: \"[0-9.]*\"/version: \"$new_version\"/g" build-push-to-ecr/WorkflowTemplate.yaml

# Update 6-cheatsheet.yaml
sed -i "s/version: \"[0-9.]*\"/version: \"$new_version\"/g" build-push-to-ecr/6-cheatsheet.yaml

echo $new_version
