#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. Usage : download page output_file"
fi

echo "downloading  $1 to $2"

source config.sh

gMonsite=$gRoot"/login"
gPaheAAtteindre="$1"
gFichierCookie="/tmp/cookie"


urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


# 1/ On récupère un 1er cookie + authentification
gTokenAuthentification=`curl "${gMonsite}" -c "${gFichierCookie}" -s 	|\
          grep csrf-token                				|\
 	  sed -e 's/.*content="//ig' -e 's/".*//ig'`
gTokenAuthentification=$(urlencode "${gTokenAuthentification}")

# 2/ On s'authentifie sur le site
curl "${gMonsite}" \
 -s \
 -b "${gFichierCookie}" \
 -c "${gFichierCookie}" \
 --data "authenticity_token=${gTokenAuthentification}" \
 --data "username=${gLogin}" \
 --data "password=${gPass}" \
 --data "login=Connexion" \
 > /dev/null

# 3/ On va à la page correspondante, en faisant un grep
curl "${gPaheAAtteindre}" \
 -s \
 -b "${gFichierCookie}" \
-o $2
