#!/bin/bash
#Converts Keep Takeouts to md files

### Work in progress
OUT_DIR="anno"
mkdir -p "$OUT_DIR"

convert_Keep() {
  local name="$1"
  #echo "$1"
  #cat "$name" | tr "," "\n"
  local lines2=$(cat "$name" | python -m json.tool )
  #mapfile -t lines < <(cat "$name" | tr "," "\n" | tr '"' ' ')
  mapfile -t lines < <(cat "$name" | tr "," "\n" | tr '"' ' ')
  #color="$(echo ${lines[0]} | sed 's/{ color : //')"
  #color="$(echo "$lines2" | grep color | sed 's/{ color : //')"
  local color="$(echo "$lines2" | jq '.color' | sed 's/\"//g')"
  local trashed="$(echo "$lines2" | jq '.trashed')"
  local title="${title:-$(echo "$lines2" | jq '.title' | sed 's/^"//' | sed 's/"$//' )}"
  #title="${title:-$(echo $color&& echo $title | awk '{print $1;}')}"
  local title="${title:-$(echo $textContent | awk '{print $1;}')}"
  local timestamp="$(echo "$lines2" | jq '.userEditedTimestampUsec')"
  local textContent="$(echo "$lines2" | jq '.textContent' | sed 's/^"//' | sed 's/"$//')"
  local isArchived="$(echo "$lines2" | jq '.isArchived')"

  local title="${title:-$(echo "$color - $(echo $textContent | awk '{print $1 " " $2 " " $3;}' )" ) }"
  #title="${title:-$(echo $textContent | awk '{print $1;}')}"

  #trashed="${lines[1]}"
  #pinned="${lines[2]}"
  #archived="${lines[3]}"
  #textContent="$( echo ${lines[4]} | sed 's/textContent ://')"
  #title="$( echo ${lines[5]} | sed 's/title :/title:/')"
  #timestamp="${lines[6]}"

  local t=$(echo $timestamp | egrep -o "[0-9]{10}")
  timestamp="$(date -d @$(echo $timestamp | egrep -o "[0-9]{10}?") +%Y-%m-%d 2>/dev/null)"
  timestamp="${timestamp:-$(basename $1 | egrep -o "^.{10}")}"
  local filename="$timestamp - $title"
  echo is $filename
  filename=$(echo "$filename" | sed 's/\//-/g')
  #filename=$(basename "$filename")
  echo is $filename
  #filename=$(printf '%q' "$filename")

  #output=$(cat << EOF
  local output="---
title: $title
date: $timestamp
labels: $color
---

  $textContent
  "
#EOF
#)
  echo "$OUT_DIR/$filename.md"
  echo "$output"
  touch "$OUT_DIR/$filename.md"
  echo "$output" > "$OUT_DIR/$filename.anno.md"

}

readarray -t files < <(find . -type f | grep json)

#convert_Keep "${files[3]}"
#exit 1
for file in "${files[@]}"
do
  convert_Keep $file
done
