#!/bin/bash
#Converts Keep Takeouts to Anno md files

#Global configuration variables
OUT_DIR="anno"
INPUT_DIR="Keep"
ARCHIVE_PATH="_archive"
IMAGE_PATH="_images"
FILE_ENDING="anno.md"

#extracts attachments from lines
get_attachments() {
  local attachments
  mkdir "$OUT_DIR/_images" 2> /dev/null


  for i in $(echo "$1" | jq -c '.attachments | keys |.[]' 2> /dev/null )
  do
    attachment="$(echo "$lines" | jq -r ".attachments[$i].filePath")"
    #echo "new attachment $attachment"
    if [ "$attachment" != "" ]
    then
      cp "$(dirname "$name")/$attachment" "$OUT_DIR/$IMAGE_PATH/" > /dev/null || true
    fi
    attachments="$attachments
![$attachment](/image/$attachment)"
  done
  echo "$attachments"
}

#Creates a labels string
get_labels() {
  local lines="$1"
  local labels
  local color
  color="$(echo "$lines" | jq -r '.color')"
  labels="$color"
  for i in $(echo "$lines" | jq -c '.annotations | keys | .[]' 2> /dev/null)
  do
    annotation="$(echo "$lines" | jq -c ".annotations[$i]")"
    labels="$labels $(echo "$annotation" | jq -r '.source' )"
  done
  echo  "$labels" | sed 's/ /, /g'
}

#Converts a Keep file
convert_Keep() {
  local name="$1"
  local lines
  lines=$(python -m json.tool < "$name")
  if [ "$lines" == "" ]
  then
    echo "File $name without content"
  fi
  local color
  color="$(echo "$lines" | jq -r '.color')"
  local textContent
  textContent="$(echo "$lines" | jq -r '.textContent')"
  local timestamp
  timestamp="$(echo "$lines" | jq -r '.userEditedTimestampUsec')"

  local title
  title="${title:-"$(echo "$lines" | jq -r '.title')"}"
  title="${title:-"$color - $(echo $textContent | awk '{print $1 " " $2 " " $3 " " $4 " " $5;}' )" }"

  local isArchived
  isArchived="$(echo "$lines" | jq -r '.isArchived')"
  local attachments
  attachments="$(echo "$lines" | jq -r '.attachments')"

  local labels
  labels="$(get_labels "$lines")"

  timestamp="$(date -d @"$(echo "$timestamp" | grep -E -o "[0-9]{10}?|0$" | head -n1)" +%Y-%m-%d)"
  timestamp="${timestamp:-$(basename "$1" | grep -E -o "^.{10}")}"
  timestamp="${timestamp:-$(date -d @0 +%Y-%m-%d)}"
  timestamp="${timestamp:testi}"
  local filename="$timestamp - $title"
  filename=$(echo "$filename" | sed 's/\//-/g')

  local outPath="$OUT_DIR"
  if [ "$isArchived" == "true" ]
  then

    outPath="$outPath/$ARCHIVE_PATH/"
  fi
  local output

  #Create the content of the file
  output="---
title: $title
date: $timestamp
labels: $labels
---

$textContent
$(get_attachments "$lines")
  "
  #Now output the result
  echo "$outPath/$filename.$FILE_ENDING"
  echo "$output"
  echo "$output" > "$outPath/$filename.$FILE_ENDING"
}

check_requirements() {
  if  ! which jq > /dev/null
  then
    echo "Please install jq"
    exit 1
  fi
}

create_output_paths() {
  mkdir -p "$OUT_DIR"
  mkdir -p "$OUT_DIR/$ARCHIVE_PATH"
  mkdir -p "$OUT_DIR/$IMAGE_PATH"
}

##main
check_requirements
create_output_paths
readarray -t files < <(find . -type f | grep json)

for file in "${files[@]}"
do
  convert_Keep "$file" #&
done
