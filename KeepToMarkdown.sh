#!/bin/bash
#Converts Keep Takeouts to md files

### Work in progress
OUT_DIR="anno"
mkdir -p "$OUT_DIR"

get_attachments() {
  #local attachments
  local attachments
  #echo "Got $1"
  #declare -a attachments=("${!1}")
  for attachment in $(echo "$1" | jq -c '.[]')
  do
    #echo "new attachment $attachment"
    attachment="$(echo "$attachment" | jq -r '.filePath')"
    #echo "Attach $attachment"
    attachments="
[$attachment]($attachment)"
  done
  echo "$attachments"
}
convert_Keep() {
  local name="$1"
  #echo "$1"
  #python -m json.tool < "$name"
  local lines2
  lines2=$(python -m json.tool < "$name")
  #mapfile -t lines < <(cat "$name" | tr "," "\n" | tr '"' ' ')
  #mapfile -t lines < <(cat "$name" | tr "," "\n" | tr '"' ' ')
  #color="$(echo ${lines[0]} | sed 's/{ color : //')"
  #color="$(echo "$lines2" | grep color | sed 's/{ color : //')"
  local color
  color="$(echo "$lines2" | jq '.color' | sed 's/\"//g')"
  #local trashed
  #trashed="$(echo "$lines2" | jq '.trashed')"
  local title
  title="${title:-$(echo "$lines2" | jq '.title' | sed 's/^"//' | sed 's/"$//' )}"
  #title="${title:-$(echo $color&& echo $title | awk '{print $1;}')}"
  local title="${title:-$(echo "$textContent" | awk '{print $1;}')}"
  local timestamp
  timestamp="$(echo "$lines2" | jq '.userEditedTimestampUsec')"
  local textContent
  textContent="$(echo "$lines2" | jq '.textContent' | sed 's/^"//' | sed 's/"$//')"
  #local isArchived
  #isArchived="$(echo "$lines2" | jq '.isArchived')"
  local attachments
  attachments="$(echo "$lines2" | jq '.attachments')"
  #echo att: "$attachments"

  local title="${title:-$("$color - $(echo "$textContent" | awk '{print $1 " " $2 " " $3;}' )" ) }"
  #title="${title:-$(echo $textContent | awk '{print $1;}')}"

  #echo timestamp is $timestamp
  #timestamp="$(date -d @$(echo $timestamp | egrep -o "[0-9]{0-10}?") +%Y-%m-%d 2>/dev/null)"
  timestamp="$(date -d @"$(echo "$timestamp" | grep -E -o "[0-9]{10}?|0$" | head -n1)" +%Y-%m-%d)"
  timestamp="${timestamp:-$(basename "$1" | grep -E -o "^.{10}")}"
  timestamp="${timestamp:-$(date -d @0 +%Y-%m-%d)}"
  timestamp="${timestamp:testi}"
  local filename="$timestamp - $title"
  #echo is $filename
  filename=$(echo "$filename" | sed 's/\//-/g')
  #filename=$(basename "$filename")
  #echo is $filename
  #filename=$(printf '%q' "$filename")

  #output=$(cat << EOF
  local output
  output="---
title: $title
date: $timestamp
labels: $color
---

$textContent
$(get_attachments "$attachments")
  "
  #EOF
  #)
  echo "$OUT_DIR/$filename.md"
  echo "$output"
  echo "$output" > "$OUT_DIR/$filename.anno.md"

}

readarray -t files < <(find . -type f | grep json)

#convert_Keep "${files[3]}"
convert_Keep "Keep/Valloric_YouCompleteMe · GitHub.json"
convert_Keep "Keep/Arbeitszeit Neujahr 2019.json"
for file in "${files[@]}"
do
  convert_Keep "$file" &
done
