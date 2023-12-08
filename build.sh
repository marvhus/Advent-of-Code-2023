#!/usr/bin/env bash

dir="$1"
if [[ ! -d $dir ]]; then
    echo "Directory '$dir' doesn't exist"
    echo "Usage: ./build.sh <directory>"
    echo "Example: ./build.sh 01"
    exit 1
fi

path="$dir/main.jai"
if [[ ! -f $path ]]; then
    echo "Path '$path' doesn't exist"
    echo "Make a main.jai file in the directory"
    exit 1
fi

set -xe

jai $path -quiet -import_dir ../modules

{ set +x; } &> /dev/null

if [[ "$2" == "run" ]]; then
    echo "=== RUNNING ==="
    $dir/main
fi

