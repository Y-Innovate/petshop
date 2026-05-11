import base64
import requests
import json

from getpass import getpass
from Globals import Globals
from MyRequests import MyRequests

Globals.myHost = "https://yinhdisv:8081"
Globals.myBasepath = ""
Globals.myCreds = ('YBTKS','')
Globals.pathPrefix = "/petshop/API/v1"
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
    respget = MyRequests.get(f"{Globals.pathPrefix}/refTables/STORSTAT?tableKey=ACTIVE")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")
    else:
        if (respget.status_code == 404):
            newRefTable = {}
            newRefTable["tableID"] = "STORSTAT"
            newRefTable["tableKey"] = "ACTIVE"
            newRefTable["tableValue"] = "Store is active"

            resppost = MyRequests.post(f"{Globals.pathPrefix}/refTables", newRefTable)

            if (resppost.status_code != 201):
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/stores?storeName_filter=Pet%20store%201&storeID_since=0")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")
    else:
        if (respget.status_code == 404):
            newStore = {}
            newStore["storeCode"] = "PS000001"
            newStore["storeStatus"] = "ACTIVE"
            newStore["storeName"] = "Pet store 1"

            resppost = MyRequests.post(f"{Globals.pathPrefix}/stores", newStore)

            if (resppost.status_code != 201):
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/suppliers?supplierName_filter=Pet%20food%20supplier%201")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")
    else:
        if (respget.status_code == 404):
            newSupplier = {}
            newSupplier["supplierCode"] = "SU000001"
            newSupplier["supplierStatus"] = "ACTIVE"
            newSupplier["supplierName"] = "Pet food supplier 1"

            resppost = MyRequests.post(f"{Globals.pathPrefix}/suppliers", newSupplier)

            if (resppost.status_code != 201):
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/products")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")
    else:
        if (respget.status_code == 404):
            newProduct = {}
            newProduct["productCode"] = "PR000001"
            newProduct["productStatus"] = "ACTIVE"
            newProduct["productName"] = "Deadbeef Dog Food"
            newProduct["groupCode"] = "PEDFCN01"
            newProduct["supplierID"] = 1

            resppost = MyRequests.post(f"{Globals.pathPrefix}/products", newProduct)

            if (resppost.status_code != 201):
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/inventory?storeID_filter=1")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")
    else:
        if (respget.status_code == 404):
            newInventory = {}
            newInventory["storeID"] = 1
            newInventory["productID"] = 1
            newInventory["sellByDate"] = "1900-01-01-00:00:00.000000"
            newInventory["inStock"] = 100

            resppost = MyRequests.post(f"{Globals.pathPrefix}/inventory", newInventory)

            if (resppost.status_code != 201):
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')
    
    respget = MyRequests.get(f"{Globals.pathPrefix}/animals?storeID_filter=1")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")
    else:
        if (respget.status_code == 404):
            newAnimal = {}
            newAnimal["storeID"] = 1
            newAnimal["animalType"] = "AT000001"
            newAnimal["animalRace"] = "AR000001"
            newAnimal["animalName"] = "Bob"
            newAnimal["animalGender"] = "M"
            newAnimal["animalAge"] = 4
            newAnimal["animalCount"] = 1

            resppost = MyRequests.post(f"{Globals.pathPrefix}/animals", newAnimal)

            if (resppost.status_code != 201):
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

#for i in range(0, 100):
doStuff()