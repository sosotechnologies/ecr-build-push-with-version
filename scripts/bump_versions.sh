#!/bin/bash

# Check if VERSIONS file exists
if [ ! -f VERSIONS ]; then
  echo -e "2.1.2\n2.1.2\n2.1.2\n2.1.2" > VERSIONS
fi

readarray -t versions < VERSIONS

bump_version() {
  local version=$1
  IFS='.' read -r -a version_parts <<< "$version"
  version_parts[2]=$((version_parts[2] + 1))
  echo "${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"
}

new_version_cpu=$(bump_version ${versions[0]})
new_version_gpu=$(bump_version ${versions[1]})
new_version_temp_world=$(bump_version ${versions[2]})
new_version_wf_world=$(bump_version ${versions[3]})

echo -e "$new_version_cpu\n$new_version_gpu\n$new_version_temp_world\n$new_version_wf_world" > VERSIONS

echo "new_version_cpu=$new_version_cpu"
echo "new_version_gpu=$new_version_gpu"
echo "new_version_temp_world=$new_version_temp_world"
echo "new_version_wf_world=$new_version_wf_world"
