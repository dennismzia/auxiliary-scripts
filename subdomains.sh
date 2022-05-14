#!/usr/bin/bash

# d=$(date +"%m-%d-%Y")
DIR=$HOME/Documents/engagements/$1
DOMAIN=$1
if [  ! -d "$DIR" ]; then
    mkdir $DIR
fi
if [[ $1 = "" ]]; then
    echo "USAGE: domain [domain domain2]"
    exit
fi
if [[ $2 != "" ]]; then
    #statements
    DOMAIN=$2
elif [[ $2 = "" ]]; then
    DOMAIN=$1
fi

echo "subdomain probe started on $DOMAIN"
echo "started subfinder"
subfinder -all -silent -d $DOMAIN |httprobe|sort -u|anew $DIR/subdomains.txt
echo "started assetfinder"
assetfinder -subs-only $DOMAIN |httprobe |sort -u|anew $DIR/subdomains.txt
# echo "Total subs found on $1 $(cat subdomains_$d.txt|wc -l)"
