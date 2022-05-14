import xml.etree.ElementTree as ET
import urllib
import base64
import math
import sys
import re

# usage: Open Burp, navigate to proxy history, ctrl-a to select all records, right click and "Save Items" as an .xml file.
# python burplist.py burprequests.xml
# output is saved to wordlist.txt

def entropy(string):
        #"Calculates the Shannon entropy of a string"
        # get probability of chars in string
        prob = [ float(string.count(c)) / len(string) for c in dict.fromkeys(list(string)) ]

        # calculate the entropy
        entropy = - sum([ p * math.log(p) / math.log(2.0) for p in prob ])

        return entropy

def avgEntropyByChar(en,length):
    # calulate "average" entropy level
    return en / length


tree = ET.parse(sys.argv[1])
root = tree.getroot()
wordlist = []

for i in root:

    # preserve subdomains, file/dir names with . - _
    wordlist += re.split('\/|\?|&|=',i[1].text)

    # get subdomain names and break up file names
    wordlist += re.split('\/|\?|&|=|_|-|\.|\+',i[1].text)

    # get words from cookies, headers, POST body requests
    wordlist += re.split('\/|\?|&|=|_|-|\.|\+|\:| |\n|\r|"|\'|<|>|{|}|\[|\]|`|~|\!|@|#|\$|;|,|\(|\)|\*|\|', urllib.unquote(base64.b64decode(i[8].text)))

    # response
    if i[12].text is not None:
        wordlist += re.split('\/|\?|&|=|_|-|\.|\+|\:| |\n|\r|\t|"|\'|<|>|{|}|\[|\]|`|~|\!|@|#|\$|;|,|\(|\)|\*|\^|\\\\|\|', urllib.unquote(base64.b64decode(i[12].text)))

auxiliaryList = list(set(wordlist))
final = []
avgEntropyByLength = {}

for word in auxiliaryList:
    if word.isalnum() or '-' in word or '.' in word or '_' in word:
        en = entropy(word)
        # remove "random strings" that are high entropy
        if en < 4.4:
            final.append(word)

final.sort()

with open('wordlist.txt', 'w') as f:
    for item in final:
        f.write("%s\n" % item)


print "wordlist saved to wordlist.txt"
