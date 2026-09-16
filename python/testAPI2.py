import base64
import requests
import json

from getpass import getpass
from Globals import Globals
from MyRequests import MyRequests

Globals.myHost = "https://t01.yinhdisv.nl:8081"
#Globals.myHost = "https://mainframeyin:8092"
Globals.myAuthHost = "https://login.microsoftonline.com/d7c088c2-6aa0-4e91-bbba-6d611f3c1bf1/oauth2/v2.0/token"
Globals.myBasepath = ""
#Globals.myCreds = ('','')
with open("/u/ybtks/.creds", "r") as credfile:
    Globals.myCreds = json.load(credfile)
Globals.pathPrefix = "/LWWAPI/API"
Globals.s = requests.sessions.Session()

if isinstance(Globals.myCreds, tuple):
    if Globals.myCreds[0] == '':
        userid = input("Give your userid: ")
        Globals.myCreds = (userid,'')

    if Globals.myCreds[1] == '':
        passwd = getpass("Give your password: ")
        Globals.myCreds = (Globals.myCreds[0], passwd)

#print("Getting bearer token")

MyRequests.getBearerToken(Globals.myAuthHost)
#MyRequests.getBearerToken(f"{Globals.pathPrefix}/token")

def doStuff():
    respget = MyRequests.get(f"{Globals.pathPrefix}/APIPath?ID_API=1")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")
    else:
        if (respget.status_code == 401):
            print("\nNot auth")
            print(f"{respget.text}")
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

for i in range(0, 1):
    doStuff()