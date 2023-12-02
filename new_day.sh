#!/usr/bin/env bash

day="$1"

if [[ -z "$day" || "$day" -eq "-h" || "$day" -eq "-help" || "$day" -eq "--help" || "$day" -eq "help" ]]; then
    echo "Usage: ./new_day.sh <day>"
    echo "Example: ./new_day.sh 01"
    exit 1
fi

if [[ "$day" != [0-9]* ]]; then
    echo "Not a number"
    echo "Day has to be a number"
    exit 1
fi

num=$(echo "[$day]pq" | dc 2>/dev/null)

if [[ ! "$num" =~ ^[0-9]+$ ]]; then
    echo "Invalid numeric value from dc"
    exit 1
fi

if (( $num < 1)) || (($num > 25 )); then
    echo "Not a valid day"
    echo "Day has to be between 1 and 25"
    exit 1
fi

if [[ ! ${#day} -eq 2 ]]; then
    echo "Day number has to be left padded so that the string has a length of two"
    exit 1
fi

if [[ -d "$day" ]]; then
    echo "Day already exists"
    exit 1
fi

set -xe

mkdir "${day}"
touch "${day}/main.jai"
