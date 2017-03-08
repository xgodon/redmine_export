#!/bin/bash

source config.sh

while read page; do
  pandoc --from textile --to dokuwiki -o /tmp/converted $page
  page=$(echo  $page | tr '[:upper:]' '[:lower:]')
  mv /tmp/converted $page

done <all_pages_output
