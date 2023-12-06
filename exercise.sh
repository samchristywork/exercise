#!/bin/bash

filename="$HOME/.exercise"

if [ ! -f "$filename" ]; then
    touch "$filename"
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi
