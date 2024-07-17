#!/bin/bash

# Read the current versions
source VERSIONS

# Bump versions (example logic to bump patch version)
new_world_version=$(echo $world_version | awk -F. -v OFS=. '{$NF++; print}')
new_cpu_version=$(echo $cpu_version | awk -F. -v OFS=. '{$NF++; print}')
new_gpu_version=$(echo $gpu_version | awk -F. -v OFS. '{$NF++; print}')
new_osm_version=$(echo $osm_version | awk -F. -v OFS=. '{$NF++; print}')

# Update the VERSIONS file with the new versions
echo "world_version=$new_world_version" > VERSIONS
echo "cpu_version=$new_cpu_version" >> VERSIONS
echo "gpu_version=$new_gpu_version" >> VERSIONS
echo "osm_version=$new_osm_version" >> VERSIONS
