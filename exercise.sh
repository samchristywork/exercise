#!/bin/bash

filename="$HOME/.exercise"

if [ ! -f "$filename" ]; then
  touch "$filename"
fi

if [ $# -eq 0 ]; then
  echo "Usage: $0 <command>"
  echo "Commands:"
  echo "  add <exercise> <reps>"
  echo "  today <exercise>"
  echo "  start <exercise> <reps> <interval>"
  echo "  goal <start time> <end time> <exercise> <start reps> <end reps>"
  echo "  show"
  echo "  edit"
  echo "  summary"
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

case "$1" in
  add)
    if [ $# -ne 3 ]; then
      echo "Usage: $0 add <exercise> <reps>"
      exit 1
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S')	$3	$2" >> "$filename"
    ;;
  start)
    if [ $# -ne 4 ]; then
      echo "Usage: $0 start <exercise> <reps> <interval>"
      exit 1
    fi
    while true; do
      ./exercise.sh add "$2" "$3"
      echo "Added $3 $2"

      ./exercise.sh today "$2"

      countdown "$4"

      read -r -p "Continue? [y/n] " yn
      case "$yn" in
        [Yy]* ) continue;;
        [Nn]* ) break;;
        * ) continue;;
      esac
    done
    ;;

    start_time="$(date -d "$2" +%s)"

  show)
    cat "$filename"
    ;;
  edit)
    "$EDITOR" "$filename"
    ;;
  *)
    echo "Unknown command: $1"
    exit 1
    ;;
esac
