import base64
import requests
import json

from getpass import getpass
from Globals import Globals
from MyRequests import MyRequests

Globals.myHost = "https://yinhdisv:8081"
#Globals.myHost = "https://mainframeyin:8092"
Globals.myBasepath = ""
Globals.myCreds = ('','')
#Globals.myCreds = ('','')
Globals.pathPrefix = "/LWWAPI/API"
Globals.s = requests.sessions.Session()

if Globals.myCreds[0] == '':
    userid = input("Give your userid: ")
    Globals.myCreds = (userid,'')

if Globals.myCreds[1] == '':
    passwd = getpass("Give your password: ")
    Globals.myCreds = (Globals.myCreds[0], passwd)

print("Getting bearer token")

MyRequests.getBearerToken(f"{Globals.pathPrefix}/token")

def doStuff():
    data = {}
    data['YAMLName'] = "/var/cicsts/lww/openapi/petshop.yaml"

    resppost = MyRequests.post(f"{Globals.pathPrefix}/APIYAML", data)

    if (resppost.status_code == 201):
        print(f"{resppost.status_code} {resppost.text}")

        myYAML = json.loads(resppost.text)

        data = {}
        data['ID_APIYAML'] = myYAML['ID_APIYAML']
        data['APIPathPrefix'] = '/petshop/API/v1'

        resppost = MyRequests.post(f"{Globals.pathPrefix}/APIYAMLParse", data)

        if (resppost.status_code == 200):
            print(f"{resppost.status_code} {resppost.text}")

            respget = MyRequests.get(f"{Globals.pathPrefix}/APIPath?ID_API={myYAML['ID_API']}")

            if (respget.status_code == 200):
                print(f"{respget.status_code} {respget.text}")

                myPaths = json.loads(respget.text)

                for APIPath in myPaths['APIPath']:
                    respget = MyRequests.get(f"{Globals.pathPrefix}/APIMethod?ID_APIPath={APIPath['ID_APIPath']}")

                    if (respget.status_code == 200):
                        print(f"{respget.status_code} {respget.text}")

                        myMethods = json.loads(respget.text)

                        for APIMethod in myMethods['APIMethod']:
                            data = {}
                            data['APIPath'] = APIPath['APIPath']
                            data['APIMethod'] = APIMethod['APIMethod']
                            data['pathWithId'] = APIMethod['pathWithId']

                            resppost = MyRequests.post(f"{Globals.pathPrefix}/APIIST", data)

                            if (resppost.status_code == 200):
                                print(f"{resppost.status_code} {resppost.text}")
                            else:
                                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
                    else:
                        raise Exception(f'status code {str(respget.status_code)} {respget.text}')
            else:
                raise Exception(f'status code {str(respget.status_code)} {respget.text}')
        else:
            raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
    else:
        raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')

doStuff()