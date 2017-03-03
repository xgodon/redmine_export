# redmine_export
bash script to download all wikis from a redmine. Done  via curl. Result is in .txt (textile by default). Thus convertible via pandoc.

original script to download a page :  https://forum.ubuntu-fr.org/viewtopic.php?id=1988093 made by chris_wafer

usage : edit config file to your needs : set username, root url, password.
then you can launch main.sh

this will construct a basic arborescence in the "page" dir

then use http://pandoc.org/ to convert the downloaded files from any markup format into another.
