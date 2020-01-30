#!/bin/bash
#Converts Keep Takeouts to md files

### Work in progress

convert_Keep() {
  name="$1"
  echo "$1"
  cat "$name" | tr "," "\n"
  lines2=$(cat "$name" | python -m json.tool )
  #mapfile -t lines < <(cat "$name" | tr "," "\n" | tr '"' ' ')
  mapfile -t lines < <(cat "$name" | tr "," "\n" | tr '"' ' ')
  #color="$(echo ${lines[0]} | sed 's/{ color : //')"
  #color="$(echo "$lines2" | grep color | sed 's/{ color : //')"
  color="$(echo "$lines2" | jq '.color' | sed 's/\"//g')"
  trashed="$(echo "$lines2" | jq '.trashed')"
  title="${title:-$(echo "$lines2" | jq '.title' | sed 's/^"//' | sed 's/"$//' )}"
  #title="${title:-$(echo $color&& echo $title | awk '{print $1;}')}"
  title="${title:-$(echo $textContent | awk '{print $1;}')}"
  timestamp="$(echo "$lines2" | jq '.userEditedTimestampUsec')"
  textContent="$(echo "$lines2" | jq '.textContent' | sed 's/^"//' | sed 's/"$//')"
  isArchived="$(echo "$lines2" | jq '.isArchived')"

  title="${title:-$(echo "$color - $(echo $textContent | awk '{print $1 " " $2 " " $3;}' )" ) }"
  #title="${title:-$(echo $textContent | awk '{print $1;}')}"

  #trashed="${lines[1]}"
  #pinned="${lines[2]}"
  #archived="${lines[3]}"
  #textContent="$( echo ${lines[4]} | sed 's/textContent ://')"
  #title="$( echo ${lines[5]} | sed 's/title :/title:/')"
  #timestamp="${lines[6]}"

  t=$(echo $timestamp | egrep -o "[0-9]{10}")
  t="${t:-$($1 | egrep -o "{10}")}"
  timestamp="$(date -d @$(echo $timestamp | egrep -o "[0-9]{10}?") +%Y-%m-%d)"
  filename="$timestamp - $title"

  #output=$(cat << EOF
  output="
  ---
  title: $title
  date: $timestamp
  labels: $color
  ---
  $textContent
  "
#EOF
#)
  echo "$output"
  echo $filename

}

readarray -t files < <(find . -type f | grep json)

convert_Keep "${files[15]}"
#for file in "${files[@]}"
#do
#  convert_Keep $file
#done
