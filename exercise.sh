#!/bin/bash

filename="$HOME/.exercise"

if [ ! -f "$filename" ]; then
    touch "$filename"
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

function countdown() {
    secs=$1
    while [ "$secs" -gt 0 ]; do
        echo -ne "$secs\033[0K\r"
        sleep 1
        : $((secs--))
    done
}
