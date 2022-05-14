#!/usr/bin/python3

from google_play_scraper import app
import json
import datetime

def App(app):
    result = app(
        'com.nianticlabs.pokemongo',
        lang='en', # defaults to 'en'
        country='us' # defaults to 'us'
    )

    print("Title: "+ result["title"])
    print("AppId: "+ result["appId"])
    print("url: "+ result["url"])
    print("Installs: " + result["installs"])
    print("minInstalls: " + str(result["minInstalls"]))
    print("Version: " + result["version"])
    print("updated: " + str( datetime.datetime.fromtimestamp(result["updated"]).strftime('%Y-%m-%d %H:%M:%S')))
# parsed = json.loads(str(result))
# print(json.dumps(parsed, indent=4, sort_keys=True))
