#!/bin/bash

source config.sh


#GET ALL PROJECTS INDEX

url_projects=$gRoot"/projects"

./download.sh $url_projects projects_page

cat projects_page | grep "/projects/" | grep href |sed -e "s|.*href=\"/projects/\([-a-z0-9/_]*\)\">.*|\1|g" > projects_list

#JUST PRINTING INFOS
n=$(wc -l projects_list)
echo "Number of projects found : $n"

#FILE AND FOLDER PREPARATION

if [ -d pages ] ; then
    rm -r pages
fi
mkdir pages
echo "all pages :" > all_pages_temp

#FOR EACH PROJECT, GET INDEX THEN GET ALL PAGES

while read project; do

  #HANS GET THE INDEX
  ./download.sh $gRoot"/projects/"$project/wiki/index index_temp
 
  #TEST IF INDEX IS EMPTY
  if grep -q "No data to display" index_temp
  then
    continue      # Skip rest of this particular loop iteration.
  fi

  #LIST ALL PAGES
  cat index_temp | grep "/projects/" | grep href | grep "/wiki/" | grep -v "/export.html" | grep -v "/export.pdf" | grep -v "/index" | sed -e "s|.*href=\".*/projects/\([-a-zA-Z0-9/_%&#().;]*\)\">.*|\1|g" > pages_temp

  #JUST A FILE TO SEE PAGES FROM ALL WIKI
  cat pages_temp >> all_pages_temp

  #GET THE PAGE NAME
  cat pages_temp | sed -e 's|.*/\([-a-zA-Z0-9/_%&#().;]*\)|\1|g' > pages_temp_clean

  mkdir ./pages/$project

  echo "-----"
  while read page; do
    page_url="$gRoot/projects/$project/wiki/$page"
    echo "downloading  $page_url"
    ./download.sh $page_url.txt ./pages/$project/$page
  done <pages_temp_clean
  
  echo tut
done <projects_list
