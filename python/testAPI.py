import base64
import requests
import json

from getpass import getpass
from Globals import Globals
from MyRequests import MyRequests

Globals.myHost = "https://yinhdisv:8081"
#Globals.myHost = "https://mainframeyin:8092"
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
    storeID = 0
    supplierID = 0
    productID = 0
    inventoryID = 0
    animalID = 0
    padID = 0

    respget = MyRequests.get(f"{Globals.pathPrefix}/refTables/STORSTAT?tableKey=ACTIVE")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")
    else:
        if (respget.status_code == 404):
            newRefTable = {}
            newRefTable["tableID"] = "STORSTAT"
            newRefTable["tableKey"] = "ACTIVE"
            newRefTable["tableValue"] = "Store is active"

            X=input('touch')
            resppost = MyRequests.post(f"{Globals.pathPrefix}/refTables", newRefTable)

            if (resppost.status_code != 201):
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/stores?storeName_filter=Pet%20store%201&storeID_since=0")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")

        storeID = respget.json()['stores'][0]['storeID']
    else:
        if (respget.status_code == 404):
            newStore = {}
            newStore["storeCode"] = "PS000001"
            newStore["storeStatus"] = "ACTIVE"
            newStore["storeName"] = "Pet store 1"

            resppost = MyRequests.post(f"{Globals.pathPrefix}/stores", newStore)

            if (resppost.status_code == 201):
                storeID = resppost.json()['storeID']
            else:
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/suppliers?supplierName_filter=Pet%20food%20supplier%201")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")

        supplierID = respget.json()['suppliers'][0]['supplierID']
    else:
        if (respget.status_code == 404):
            newSupplier = {}
            newSupplier["supplierCode"] = "SU000001"
            newSupplier["supplierStatus"] = "ACTIVE"
            newSupplier["supplierName"] = "Pet food supplier 1"

            resppost = MyRequests.post(f"{Globals.pathPrefix}/suppliers", newSupplier)

            if (resppost.status_code == 201):
                supplierID = resppost.json()['supplierID']
            else:
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/products")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")

        productID = respget.json()['products'][0]['productID']
    else:
        if (respget.status_code == 404):
            newProduct = {}
            newProduct["productCode"] = "PR000001"
            newProduct["productStatus"] = "ACTIVE"
            newProduct["productName"] = "Deadbeef Dog Food"
            newProduct["groupCode"] = "PEDFCN01"
            newProduct["supplierID"] = supplierID

            resppost = MyRequests.post(f"{Globals.pathPrefix}/products", newProduct)

            if (resppost.status_code == 201):
                productID = resppost.json()['productID']
            else:
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/inventory?storeID_filter={storeID}")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")

        inventoryID = respget.json()['inventory'][0]['inventoryID']
    else:
        if (respget.status_code == 404):
            newInventory = {}
            newInventory["storeID"] = storeID
            newInventory["productID"] = productID
            newInventory["sellByDate"] = "1900-01-01-00:00:00.000000"
            newInventory["inStock"] = 100

            resppost = MyRequests.post(f"{Globals.pathPrefix}/inventory", newInventory)

            if (resppost.status_code == 201):
                inventoryID = resppost.json()['inventoryID']
            else:
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')
    
    respget = MyRequests.get(f"{Globals.pathPrefix}/animals?storeID_filter={storeID}")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")

        animalID = respget.json()['animalEntry'][0]['animalID']
    else:
        if (respget.status_code == 404):
            newAnimal = {}
            newAnimal["storeID"] = storeID
            newAnimal["animalType"] = "AT000001"
            newAnimal["animalRace"] = "AR000001"
            newAnimal["animalName"] = "Bob"
            newAnimal["animalGender"] = "M"
            newAnimal["animalAge"] = 4
            newAnimal["animalCount"] = 1

            resppost = MyRequests.post(f"{Globals.pathPrefix}/animals", newAnimal)

            if (resppost.status_code == 201):
                animalID = resppost.json()['animalID']
            else:
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

    respget = MyRequests.get(f"{Globals.pathPrefix}/pricesAndDiscounts")

    if (respget.status_code == 200):
        print(f"{respget.status_code} {respget.text}")

        padID = respget.json()['priceAndDiscount'][0]['padID']
    else:
        if (respget.status_code == 404):
            newPAD = {}
            newPAD['storeID'] = storeID
            newPAD['productID'] = productID
            newPAD['animalID'] = animalID
            newPAD['price'] = 219.9
            newPAD['discount'] = -10
            newPAD['fromDate'] = "1900-01-01-00:00:00.000000"
            newPAD['toDate'] = "1900-01-01-00:00:00.000000"

            x=input('blub')

            resppost = MyRequests.post(f"{Globals.pathPrefix}/pricesAndDiscounts?lww_debug=3", newPAD)

            if (resppost.status_code == 201):
                padID = resppost.json()['padID']
            else:
                raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')
        else:
            raise Exception(f'status code {str(respget.status_code)} {respget.text}')

#for i in range(0, 100):
doStuff()