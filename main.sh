#!/bin/bash

source config.sh

# README
# page refers at the part of the redmine url after the root : in redmine.exemple.com/projects
# redmine.exemple.com is the root
# /projects is the page


get_attachments_from_html_file () {
  file=$1 
  output_file=$2
  cat $1 | grep "icon icon-attachment" | sed -e "s|.*href=\".*\(/attachments/download/[-a-zA-Z0-9/_%&#().;]*\)\">.*|\1|g" > $2
}

# download the attachemetn of the page given in first arg and put it in the project folder given in the second arg
download_attachments () {
  local page=$1
  local folder=$2
  local temp=/tmp/page_temp_clean_att
  
  get_attachments_from_html_file $page $temp
  download_from_file $temp $folder

}

# download all url given in file ($1) to a dir ($2)
download_from_file () {
  local file=$1
  local folder=$2
  local page_url
  local output


  while read page; do
    page_url="$gRoot$page"
    output=$(echo $page | sed -e 's:.*/\(.*\):\1:g')    
    #./download.sh $page_url $folder/$output
    create_page $page_url $folder/$output
  done <$file
}

get_all_projects (){
  local temp=/tmp/projects_page
  ./download.sh $gRoot"/projects" $temp
  cat $temp | grep "/projects/" | grep href |sed -e "s|.*href=\"/projects/\([-a-z0-9/_]*\)\">.*|\1|g" | grep infra > /tmp/projects_list 

  #JUST PRINTING INFOS
  n=$(wc -l /tmp/projects_list)
  echo "Number of projects found : $n"
}

clean_wd () {

  if [ -d pages ] ; then
      rm -r pages
  fi
  if [ -d media ] ; then
      rm -r media
  fi
  mkdir pages
  mkdir media
  rm all_pages_temp all_pages_output
  touch all_pages_temp
  touch all_pages_output

}

get_parents () {

  local file=$1
  local output_file=$2
  $saxon_lint_path --html  --xpath '//p[@class = "breadcrumb"]/a/@href/string()'  $file  | sed '/^$/d'> $output_file

}

get_path (){

  local file=$1
  local page=$2
  local lines=`wc -l $file | cut -f1 -d' '`
  local temp=/tmp/path_temp

  case $lines in
    0) echo pages/$project/$project$output_format > $temp ;;
    1) echo pages/$project/$page$output_format > $temp;;
    *) local upper=$(cat $file | sed -e 's:.*/\(.*\):\1:g' |  tail -n +2 |  paste -sd "/")
       echo  pages/$project/$upper/$page/$page$output_format > $temp ;;
  esac
}

create_page () {
  local url=$1
  local output_path=$2
  local folder=$(echo $output_path | sed -e 's:\(.*\)/.*:\1:g')
  mkdir -p -- $folder
  ./download.sh $url $output_path

}

get_all_projects

clean_wd


#FOR EACH PROJECT, GET INDEX THEN GET ALL PAGES

while read project; do

  echo "PROJECT : $project"

  #HANS GET THE INDEX
  ./download.sh $gRoot"/projects/"$project/wiki/index /tmp/index_temp
 
  #TEST IF INDEX IS EMPTY
  if grep -q "No data to display" /tmp/index_temp
  then
    continue      # Skip rest of this particular loop iteration.
  fi

  #LIST ALL PAGES
  #cat index_temp | grep "/projects/" | grep href | grep "/wiki/" | grep -v "/export.html" | grep -v "/export.pdf" | grep -v "/index" | sed -e "s|.*href=\".*/projects/\([-a-zA-Z0-9/_%&#().;]*\)\">.*|\1|g" > pages_temp
  $saxon_lint_path --html  --xpath '//div[@id = "content"]/descendant-or-self::node()/@href/string()'  /tmp/index_temp | grep ^/projects | grep -Ev '/activity.atom|/wiki/new|/wiki/export.html|/wiki/export.pdf' > /tmp/pages_temp

  #JUST A FILE TO SEE PAGES FROM ALL WIKI
  cat /tmp/pages_temp >> all_pages_temp

  #GET THE PAGES NAME
  cat /tmp/pages_temp | sed -e 's|.*/\([-a-zA-Z0-9/_%&#().;]*\)|\1|g' > /tmp/pages_temp_clean

  mkdir ./pages/$project

  echo "-----"
  while read page_clean; do
    page_url="$gRoot/projects/$project/wiki/$page_clean"
   
    ./download.sh $page_url /tmp/page_temp 
    download_attachments /tmp/page_temp ./media/$project
    get_parents /tmp/page_temp /tmp/page_parents_temp
    get_path /tmp/page_parents_temp $page_clean
    page_path=$(cat /tmp/path_temp)
    create_page "$page_url$output_format" $page_path
    echo $page_path >> all_pages_output

  done </tmp/pages_temp_clean
  
  
done </tmp/projects_list

if $convert
then
  ./textile_to_doku.sh
fi 

