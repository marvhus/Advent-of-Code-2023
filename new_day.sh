#!/usr/bin/env bash

day="$1"

set -xe

mkdir "${day}"
cp template.jai "${day}/main.jai"
touch "${day}/test.txt"
