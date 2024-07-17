#!/bin/bash

# Check if VERSION file exists
if [ ! -f VERSION-CPU-TASK ]; then
  echo "2.1.2" > VERSION-CPU-TASK
fi

current_version=$(cat VERSION-CPU-TASK)

IFS='.' read -r -a version_parts <<< "$current_version"
version_parts[2]=$((version_parts[2] + 1))
new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

# Write the new version back to the VERSION file
echo $new_version > VERSION-CPU-TASK

echo $new_version