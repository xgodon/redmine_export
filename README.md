# redmine_export
bash script to download all wikis from a redmine. Done  via curl. Result is in .txt (textile by default). Thus convertible via pandoc.

The code is a bit messy cause i started to sed/grep a lot of things then thought "hey what about xpath"

So i used saxon-lint in a code portion and sed/grep in others.

original script to download a page :  https://forum.ubuntu-fr.org/viewtopic.php?id=1988093 made by chris_wafer

## TODO :

todo : keep internal links

## Prerequisite :

### saxon-lint : 

$ git clone https://github.com/sputnick-dev/saxon-lint.git
$ cd saxon-lint*
$ chmod +x saxon-lint.pl
$ ./saxon-lint.pl --help


### Pandoc : 

use http://pandoc.org/ to convert the downloaded files from any markup format into another.

sudo apt-get install pandoc will get you a too old version so you will have to visit http://pandoc.org/installing.html#linux

usage exemple :
pandoc -f textile --to dokuwiki -o output pages/project/page




## Usage :

edit config file to your needs : set username, root url, password...

launch main.sh

this will construct an arborescence in the "page" dir and put all media in the "media" dir


