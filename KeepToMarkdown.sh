#!/bin/bash
#Converts Keep Takeouts to md files

### Work in progress

convert_Keep() {
  name="$1"
  echo "$1"
  echo `cat "$name" | tr "," "\n"`
  mapfile -t lines < <(cat "$name" | tr "," "\n" | tr '"' ' ')
  color="$(echo ${lines[0]} | sed 's/{ color : //')"
  trashed="${lines[1]}"
  pinned="${lines[2]}"
  archived="${lines[3]}"
  textContent="$( echo ${lines[4]} | sed 's/textContent ://')"
  title="$( echo ${lines[5]} | sed 's/title :/title:/')"
  timestamp="${lines[6]}"

  t=$(echo $timestamp | egrep -o "[0-9]{10}")
  timestamp="$(date -d @$(echo $timestamp | egrep -o "[0-9]{10}?") +%Y-%m-%d)"

  echo ---
  echo $title
  echo date: $timestamp
  echo labels: $color
  echo ---
  echo
  echo $textContent
}

readarray -t files < <(find . -type f | grep json)

convert_Keep "${files[5]}"
#for file in "${files[@]}"
#do
#  convert_Keep $file
#done
