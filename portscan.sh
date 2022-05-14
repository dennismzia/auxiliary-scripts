# !/usr/bin/bash
# fast portscanning tool based on nmap

naabu -silent -host $1
# naabu -silent -host $(cat subdomains.txt |cut -d "/" -f3)

# DIR=$HOME/Documents/engagements/$1
# subdomains=$DIR/subdomains.txt
# # cat $subdomains
# if [[ ! -f $DIR/stripped.txt ]]; then
#     cat $DIR/subdomains.txt |cut -d "/" -f3| anew stripped.txt
#     echo "file should be created oterwise im calling quits"

# else
#     cat $DIR/stripped.txt
#     echo "fucking comand doesnt run"
# fi
# cat $dir/subdomains.txt |cut -d "/" -f3| anew aaa.txt
# echo "stripped file created"
# naabu -silent -iL striped.txt >> ports_tetative.txt
# httpx -l $dir/ports_tetative.txt -silent -random-agent -title -tech-detect -status-code -follow-redirects  -x all -sr $dir/liveports.txt
