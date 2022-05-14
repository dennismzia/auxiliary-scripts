# !/usr/bin/bash
# USAGE recon.sh domain.com burpcollab.net

DIR=$HOME/Documents/engagements/$1

httpxcall='httpx -silent -threads 5 -ports 80,81,300,443,591,593,832,981,1010,1311,1099,2082,2095,2096,2480,3000,3128,3333,4243,4443,4444,4567,4711,4712,4993,5000,5104,5108,5280,5281,5601,5800,6543,7000,7001,7396,7474,8000,8001,8008,8014,8042,8060,8069,8080,8081,8083,8088,8090,8091,8095,8118,8123,8172,8181,8222,8243,8280,8281,8333,8337,8443,8444,8500,8800,8834,8880,8881,8888,8983,9000,9001,9043,9060,9080,9090,9091,9200,9443,9502,9800,9981,10000,10250,11371,12443,15672,16080,17778,18091,18092,20720,32000,55440,55672 -random-agent'


server=$2
if [[ $server = "" ]]; then
    echo "please specify collaborator server to be used"
    echo "USAGE: recon.sh domain.com burpcollab.net"
    exit 1
fi

# fetching subdomains from custom tools fixed together.
if [ ! -f $DIR/subdomains.txt ]; then
    subdomains.sh $1
    echo "finished fetching subdomains"
    sleep 1.5
else
    echo "subdomains file found so skipping subenum"
fi

# fetching links from wayback machine and other indexing engines
if [[ ! -f $DIR/urls.txt ]]; then
    echo "started gau"
    cat $DIR/subdomains.txt|gau -random-agent |sort -u |anew $DIR/urls.txt
    echo ""
    echo "started wayback"
    cat $DIR/subdomains.txt|sort -u|anew DIR/urls.txt
else
    echo "urls from archives already exists so skipping..."
fi


# urlscan.io api call (doesnt work tho)
if [[ ! -f $DIR/urlscan.txt ]]; then
    echo "scanning urls from urlscan.io "
    for url in $(cat $DIR/subdomains.txt); do
        url.sh $url >> $DIR/urlscan.txt
    done
else
    echo "urlscan.txt found so skipping step..."
fi


# cat subdomains.txt|xargs -n1 -I % bash -c "paramspider.py -d % --exclude woff,css,js,png,svg,php,jpg -l high -o ~/Documents/engagements/hackerone.com/paramspider.txt"

# fetching links hidden in javascript files plus also (possible) secrets.
if [[ ! -f  $DIR/hiddenlinks.txt ]]; then
    echo "started astra (finding links from urls)"
    cat $DIR/subdomains.txt |astra.py -t 10 |anew $DIR/hiddenlinks.txt
    # cat $DIR/subdomains.txt|xargs -n1 -I % bash -c curl -s "https://urlscan.io/api/v1/search/?q=domain:$1" | grep -E '"url"' | cut -d '"' -f4 | grep -F $1 | sort -u|anew urlscan.txt
else
    echo "hidden links found so skipping step..."
fi

# httpx probing 
if [[ ! -f $DIR/live-scheme.txt ]]; then
    echo "[httpx] portscan test "
    $httpxcall -l $DIR/subdomains.txt -o $DIR/live-scheme.txt
else
    echo "portscheme file found so skipping... "
fi

# vulns and cve scanning. 
if [[ ! -f $DIR/nuclei_output && ! -f $DIR/nuclei_tech_output ]]; then
    echo
    echo "[nuclei] technologies testing..."
    nuclei -c 5 -silent -l $DIR/live-scheme.txt -t $DIR/nuclei-templates/technologies/ -o $DIR/nuclei/nuclei_output_technology.txt
    echo
    echo "[nuclei] CVE testing"

    nuclei -v -c -trace-log $DIR/nuclei/nucleilog -o $DIR/nuclei/nuclei_output.txt \
                        -l $DIR/live-scheme.txt \
                        -t $HOME/nuclei-templates/vulnerabilities/ \
                        -t $HOME/nuclei-templates/cves/2014/ \
                        -t $HOME/nuclei-templates/cves/2015/ \
                        -t $HOME/nuclei-templates/cves/2016/ \
                        -t $HOME/nuclei-templates/cves/2017/ \
                        -t $HOME/nuclei-templates/cves/2018/ \
                        -t $HOME/nuclei-templates/cves/2019/ \
                        -t $HOME/nuclei-templates/cves/2020/ \
                        -t $HOME/nuclei-templates/cves/2021/ \
                        -t $HOME/nuclei-templates/misconfiguration/ \
                        -t $HOME/nuclei-templates/network/ \
                        -t $HOME/nuclei-templates/miscellaneous/ \
                        -exclude $HOME/nuclei-templates/miscellaneous/old-copyright.yaml \
                        -exclude $HOME/nuclei-templates/miscellaneous/missing-x-frame-options.yaml \
                        -exclude $HOME/nuclei-templates/miscellaneous/missing-hsts.yaml \
                        -exclude $HOME/nuclei-templates/miscellaneous/missing-csp.yaml \
                        -t $HOME/nuclei-templates/takeovers/ \
                        -t $HOME/nuclei-templates/default-logins/ \
                        -t $HOME/nuclei-templates/exposures/ \
                        -t $HOME/nuclei-templates/exposed-panels/ \
                        -t $HOME/nuclei-templates/exposures/tokens/generic/credentials-disclosure.yaml \
                        -t $HOME/nuclei-templates/exposures/tokens/generic/general-tokens.yaml \
                        -t $HOME/nuclei-templates/fuzzing/
    echo "[nuclei] CVE testing done."
fi

# categorizing based on vuln type.
cat $DIR/urls.txt|gf ssrf|sort -u|anew $DIR/ssrf.txt
cat $DIR/urls.txt|gf redirect|sort -u|anew $DIR/ssrf.txt
cat $DIR/urls.txt|gf xss|sort -u|anew $DIR/xss.txt
# cat $DIR/urls.txt|gf lfi|sort -u|anew $DIR/lfi.txt
# cat $DIR/urls.txt|gf ssti|sort -u|anew $DIR/ssti.txt

# ssrf probe (interactsh will be used in future)
if [[ ! -f $DIR/ssrf_auto-ffuf.txt ]]; then
    echo "started ssrf probe"
    cat $DIR/ssrf.txt|qsreplace $server >> $DIR/ssrftemp.txt
    ffuf -t 5 -w $DIR/ssrftemp.txt -u FUZZ -o $DIR/ssrf_suspects.txt
else
    echo "ssrftest filefound so skipping step..."
fi

# open redirect probe.
if [[ ! -f $DIR/openredir.txt ]]; then
    echo""
    echo "started openredirect probe"
    cat $DIR/ssrf.txt|qsreplace "FUZZ" >> $DIR/openredir.txt
    payloads=$HOME/softwares/OpenRedireX/payloads.txt
    openredirex.py -l $DIR/openredir.txt -p $payloads >> $DIR/openredirect_suspects.txt
else
    echo "openredir file found so skipping step."
fi

# tentative xss search.
if [[ ! -f $DIR/xss-suspects.txt  ]]; then
    echo "started xss probe.This may take some time..."
    cat $DIR/xss.txt | qsreplace "xsst<>" >> $DIR/temp.txt
    config=$DIR/config

    for i in $(cat $DIR/temp.txt) ; do
        if [[ $config != "" ]]; then
            if [[ $(curl --silent -k config $i | grep "xsst<>" ) != '' ]]; then
                echo $i >> $DIR/xss-suspects.txt
            fi
        elif [[ $(curl --silent $i | grep "xsst<>" ) != ''  ]]; then
            echo $i >> $DIR/xss-suspects.txt
        else
            echo "no relfections foundish"
        fi
    done
else
    echo "xss suspects file found so skipping..."
fi

# UNCOMMENT IN ORDER TO PROBE FOR LFI
# if [[ ! -f $DIR/lfi_suspects.txt ]]; then
#     echo "started lfi probe "
#     httpx -l lfi.txt -paths $HOME/softwares/lfi_wordlist.txt -threads 10 -random-agent -x GET,POST,PUT  -tech-detect -status-code  -follow-redirects -title -mc 200 -match-regex "root:[x*]:0:0:" >> lfi_suspects.txt
# else
#     echo "found lfi suspects file so skipping..."
# fi

echo ""
sleep 1.5
echo "...finsihed..."

