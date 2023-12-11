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
  echo "  summary <date>"
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
  today)
    if [ $# -ne 2 ]; then
      echo "Usage: $0 today <exercise>"
      exit 1
    fi
    date=$(date +%Y-%m-%d)
    grep "$date" "$filename" | grep "$2" | \
    awk -F '\t' '
          BEGIN {sum=0}
          {sum+=$2}
        END {print sum, "today"}'
    ;;
  start)
    if [ $# -ne 4 ]; then
      echo "Usage: $0 start <exercise> <reps> <interval>"
      exit 1
    fi
    while true; do
      "$0" add "$2" "$3"
      echo "Added $3 $2"

      "$0" today "$2"

      countdown "$4"

      read -r -p "Continue? [y/n] " yn
      case "$yn" in
        [Yy]* ) continue;;
        [Nn]* ) break;;
        * ) continue;;
      esac
    done
    ;;
  goal)
    if [ $# -ne 6 ]; then
      echo "Usage: $0 goal <start time> <end time> <exercise> <start reps> <end reps>"
    fi

    start_time="$(date -d "$2" +%s)"
    end_time="$(date -d "$3" +%s)"
    exercise="$4"
    start_reps="$5"
    end_reps="$6"

    while :; do
      current_time="$(date +%s)"
      awk -F '\t' -v start_time="$start_time" -v end_time="$end_time" -v exercise="$exercise" -v start_reps="$start_reps" -v end_reps="$end_reps" -v current_time="$current_time" '
        END {
          estimated_progress = (current_time - start_time) / (end_time - start_time)
          estimated_reps = start_reps + (end_reps - start_reps) * estimated_progress
          print "Estimated reps for " exercise ": " estimated_reps
        }
      ' "$filename"
      "$0" today "$exercise"
      sleep 1
    done
    ;;
  show)
    cat "$filename"
    ;;
  edit)
    "$EDITOR" "$filename"
    ;;
  summary)
    date=$(date +%Y-%m-%d)

    if [ $# -eq 2 ]; then
      date="$2"
    fi

    grep "$date" "$filename" | \
    awk -F '\t' '
        BEGIN {
          categories["curls"] = 0
          categories["pullups"] = 0
          categories["pushups"] = 0
          categories["endurance"] = 0
        }
        {
          categories[$3] += $2
        }
        END {
          for (category in categories) {
            print category, categories[category]
          }
        }
        '
    ;;
  *)
    echo "Unknown command: $1"
    exit 1
    ;;
esac
