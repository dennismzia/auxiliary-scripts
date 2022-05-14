# !/usr/bin/bash

dir=$HOME/Documents/engagements/$1
# UNCOMMENT FIRST LINE TO RUN nmap AGINST ALL SUBDOMAINS (guzzles bandwidth and time)
# nmap -sS --version-intensity 5 -iL $dir/subdomains.txt -oN $dir/ports_tentative.txt
# UNCOMMENT LINE TO RUN nmap AGAINST SINGLE HOST (for standard use)
# nmap -sS --version-intensity 5 -oN $dir/ports_tentative.txt $1
if [[ $2 = "" ]]; then
    echo "None provided so defaulting to short"
    nmap -sS --version-intensity 5 -oN $dir/ports_tentative.txt $1
    for port in $(cat $dir/ports_tentative.txt |grep tcp |cut -d "/" -f1); do
            url="${tld}:${port}"
            echo $url >> $DIR/liveports.txt
        done
    httpx -l $DIR/liveports.txt -silent -random-agent -title -tech-detect -status-code -follow-redirects -sr $dir/tentativeports.txt

elif [[ $2 = "long" ]]; then
    echo "${2} provided"
    nmap -sS --version-intensity 5 -iL $dir/subdomains.txt -oN $dir/ports_tentative.txt
    for tld in $(cat $dir/subdomains.txt); do
        for port in $(cat $dir/ports_tentative.txt |grep tcp |cut -d "/" -f1); do
            url="${tld}:${port}"
            echo $url >> $DIR/liveports.txt
        done
    done
    httpx -l $DIR/liveports.txt -silent -random-agent -title -tech-detect -status-code -follow-redirects  -x all -sr $dir/tentativeports.txt

else
    echo "USAGE: noti sudo portscan.sh domain.com (short|long) "
    exit 1
fi
# liveports file might contain over 50,000 hosts or more use sparingly.
# httpx -l $DIR/liveports.txt -random-agent -title -tech-detect -status-code -follow-redirects -web-server -x all -sr $dir/tentativeports.txt

