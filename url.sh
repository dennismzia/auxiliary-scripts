#!/usr/bin/bash
# curl -s "https://urlscan.io/api/v1/search/?q=domain:$1" | grep -E '"url"' | cut -d '"' -f4 | grep -F $1 | sort -u

DIR=$HOME/Documents/engagements/$1
if [  ! -d "$DIR" ]; then
    mkdir $DIR
    echo "$1 not found on system so created one"
    echo ""
fi
if [[ $1 = "" ]]; then
    echo "USAGE: [domain sub.domain.com]"
    exit
fi
domain=$2
echo "archive search for $domain started"
echo "started gauplus"
echo "$domain"|gauplus -b ttf,woff,svg,png,jpg  -random-agent |sort -u |anew $DIR/urls.txt
echo ""
echo "started wayback"
echo "$domain"|waybackurls|sort -u|anew DIR/urls.txt
