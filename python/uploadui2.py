import os
import requests
import base64
import json
import re
import yaml
import sys
import subprocess

from getpass import getpass
from pathlib import Path
from Globals import Globals
from MyRequests import MyRequests
from pathlib import Path

Globals.myHost = "https://t01.yinhdisv.nl:8081"
#Globals.myHost = "https://mainframeyin:8092"
Globals.myAuthHost = "https://login.microsoftonline.com/d7c088c2-6aa0-4e91-bbba-6d611f3c1bf1/oauth2/v2.0/token"
Globals.myBasepath = ""
#Globals.myCreds = ('YBTKS','')
with open(f"{Path.home()}/.creds", "r") as credfile:
    Globals.myCreds = json.load(credfile)
Globals.myDebug = 0
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
#MyRequests.getBearerToken("/LWWAPI/API/token")

dir = "/home/bobby/Y-Innovate/software/git/petshop/v1/petshop-backend/ui"

os.chdir(dir)

threesix = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

nr = 2592

def nextFileId():
    global nr
    global threesix

    nr = nr + 1

    a, b = divmod(nr, 1296)

    letter1 = threesix[a]

    c, d = divmod(b, 36)

    letter2 = threesix[c]

    letter3 = threesix[d]

    return f"PTSHP{letter1}{letter2}{letter3}"

def applyOverrides(data, path, key):
    # A hidden file .<name> next to the file or folder <name> overrules fields of the payload,
    # e.g. "newFile:" for files and "newFolder:" for folders
    overrideFileName = os.path.join(os.path.dirname(path), f".{os.path.basename(path)}")

    if (os.path.isfile(overrideFileName)):
        with open(overrideFileName,'r') as overrideFile:
            overrides = yaml.safe_load(overrideFile)

        if overrides and key in overrides and overrides[key]:
            for k in overrides[key]:
                data[k] = overrides[key][k]

def overrideChanged(relpath):
    # True when the hidden override file .<name> of the file or folder <name> is changed,
    # added or deleted in the working tree, so <name> must be sent again
    x = relpath.rfind("/")

    overrideRelpath = f"{relpath[:x+1]}.{relpath[x+1:]}"

    return overrideRelpath in workingTreeUpdates or overrideRelpath in workingTreeDeletes

def createDir(someDir, id, parentId, custom):
    global dir

    n = len(dir)

    print(f"Create dir {someDir[n+1:]}")

    x = re.search(".*\\/([^\\/]*)$", someDir)

    data = {}
    if not id:
        data['folderId'] = ""
        data['generateId'] = "Y"
    else:
        data['folderId'] = id
        data['generateId'] = "N"
    data['parentFolderId'] = parentId
    data['folderName'] = x.group(1)
    data['path'] = f"/petshop/{someDir[n:]}"
    data['custom'] = custom

    applyOverrides(data, someDir, 'newFolder')

    if Globals.myDebug > 0:
        print(f"{data['folderId']} {data['folderName']}")

    resppost = MyRequests.post("/LWWAPI/Admin/folders", data)

    if (resppost.status_code >= 400):
        raise Exception('status code ' + str(resppost.status_code))

    if Globals.myDebug > 0:
        print(f"\n{resppost.status_code} {resppost.text}")

    createdDir = json.loads(resppost.text)

    return createdDir['folderId']

def updateDir(someDir, id, parentId, custom):
    global dir

    n = len(dir)

    print(f"Update dir {someDir[n+1:]}")

    x = re.search(".*\\/([^\\/]*)$", someDir)

    data = {}
    data['folderId'] = id
    data['parentFolderId'] = parentId
    data['folderName'] = x.group(1)
    data['path'] = f"/petshop/{someDir[n:]}"
    data['generateId'] = "N"
    data['custom'] = custom

    applyOverrides(data, someDir, 'newFolder')

    if Globals.myDebug > 0:
        print(f"{data['folderId']} {data['folderName']}")

    respput = MyRequests.put(f"/LWWAPI/Admin/folders/{data['folderId']}", data)

    if (respput.status_code >= 400):
        raise Exception('status code ' + str(respput.status_code))

    if Globals.myDebug > 0:
        print(f"\n{respput.status_code} {respput.text}")

def uploadFile(f, id, parentId, custom, found):
    global dir
    global workingTreeUpdates

    _custom = custom
    
    x = re.search("[^\\/]*\\.([^.]*)$", f)

    mediaType = "text/plain"

    if x:
        if (x.group(1) == "js" or x.group(1) == "jsx"):
            mediaType = "text/javascript"
        elif (x.group(1) == "png"):
            mediaType = "image/png"
        elif (x.group(1) == "md"):
            mediaType = "text/markdown"
        elif (x.group(1) == "json"):
            mediaType = "application/json"
        elif (x.group(1) == "gif"):
            mediaType = "image/gif"
        elif (x.group(1) == "css" or x.group(1) == "less"):
            mediaType = "text/css"
        elif (x.group(1) == "html"):
            mediaType = "text/html"
        elif (x.group(1) == "svg"):
            mediaType = "image/svg+xml"
        elif (x.group(1) == "woff2"):
            mediaType = "font/woff2"
        else:
            mediaType = f"text/plain"
    
    x = re.search("(.*\\/)([^\\/]*)$", f)

    relpath = x.group(1)[len(dir)+1:]
    relpath = relpath + x.group(2)

    if relpath in workingTreeUpdates:
        cmdline = f"git -C '{x.group(1)}' hash-object {x.group(2)}"

        rsltGitHashObj = subprocess.run([cmdline], shell=True, cwd=x.group(1), stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        if rsltGitHashObj.returncode:
            print(rsltGitHashObj.stdout)
            print(rsltGitHashObj.stderr)
            sys.exit(f"git hash-object returned {rsltGitHashObj.returncode}")

        calculatedHash = rsltGitHashObj.stdout.decode(encoding='utf-8').splitlines()[0]

        if calculatedHash == found and not overrideChanged(relpath):
            return
        else:
            _custom = calculatedHash

    print(f"Update file {id} {mediaType} {relpath} {_custom}")

    with open(f,'rb') as file:
        fileContents = file.read()

    fileContentsB64 = base64.b64encode(fileContents).decode("ascii")

    newFile = {}
    if not id:
        newFile['fileId'] = ""
        newFile['generateId'] = "Y"
    else:
        newFile['fileId'] = id
        newFile['generateId'] = "N"
    newFile['fileType'] = "W"
    newFile['folderId'] = parentId
    newFile['fileName'] = x.group(2)
    newFile['mediaType'] = mediaType
    newFile['preventCache'] = "N"
    newFile['storeBinary'] = "Y"
    newFile['custom'] = _custom

    applyOverrides(newFile, f, 'newFile')

    resppost = MyRequests.post("/LWWAPI/Admin/files", None, {'jsondata': (None, json.dumps(newFile)), 'contents': (None, fileContentsB64)})

    if resppost.status_code >= 400:
        raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')

    if Globals.myDebug > 0:
        print(f"{resppost.status_code} {resppost.text}")

def deleteFile(id, fileName):
    print(f"Delete file {id} {fileName}")

    respdelete = MyRequests.delete(f"/LWWAPI/Admin/files/{id}")

    if respdelete.status_code >= 400 and respdelete.status_code != 404:
        raise Exception(f'status code {str(respdelete.status_code)} {respdelete.text}')

    if Globals.myDebug > 0:
        print(f"{respdelete.status_code} {respdelete.text}")

def doDir(someDir, parentId, folderHash):
    global commitHash
    global dir
    global workingTreeUpdates
    global workingTreeUpdatesDirs
    global workingTreeDeletes
    global workingTreeDeletesDirs
    global neededDirs

    respget = MyRequests.get(f"/LWWAPI/Admin/files?folderId={parentId}")

    jsonresp = ""

    if respget.status_code == 200:
        jsonresp = respget.text
    else:
        if respget.status_code == 404:
            jsonresp = '{"folderContents":[]}'
        else:
            raise Exception(f"{respget.status_code} {respget.text}")
    
    folderContents = json.loads(jsonresp)
    
    # List the folder from the committed tree, run from the content root so it also works for
    # folders that were deleted from the working tree (their files still need deleting on the server).
    relDir = someDir[len(dir)+1:]

    if len(relDir) > 0:
        cmdline = f"git -C '{dir}' ls-tree {commitHash} -- '{relDir}/'"
    else:
        cmdline = f"git -C '{dir}' ls-tree {commitHash}"

    rsltGitLsTree = subprocess.run([cmdline], shell=True, cwd=dir, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if rsltGitLsTree.returncode:
        print(rsltGitLsTree.stdout)
        print(rsltGitLsTree.stderr)
        sys.exit(f"git ls-tree returned {rsltGitLsTree.returncode}")

    outGitLsTree = rsltGitLsTree.stdout.decode(encoding='utf-8').splitlines()

    # ls-tree prints the names with the folder path in front; keep just the names
    if len(relDir) > 0:
        outGitLsTree = [l.replace(f"\t{relDir}/", "\t", 1) for l in outGitLsTree]

    gitFiles = []
    gitFolders = []

    for l in outGitLsTree:
        x = re.search("(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S*)", l)

        if not x:
            print(l)
            print(x)
            raise Exception("error parsing ls-tree output")

        if x.group(2) == "blob":
            relpath = someDir[len(dir)+1:]
            if len(relpath) > 0:
                relpath = relpath + "/"
            relpath = relpath + x.group(4)
            gitFiles.append({ "fileName": x.group(4), "hash": x.group(3), "relpath": relpath })
        elif x.group(2) == "tree":
            subdir = someDir[len(dir)+1:]
            if len(subdir) > 0:
                subdir = subdir + "/"
            subdir = subdir + x.group(4)
            gitFolders.append({ "folderName": x.group(4), "hash": x.group(3), "dir": subdir })

    for neededDir in neededDirs:
        x = neededDir.rfind("/")

        if x < 0:
            folderName = neededDir
            parentDir = dir
        else:
            folderName = neededDir[x+1:]
            parentDir = f"{dir}/{neededDir[:x]}"

        if parentDir == someDir:
            found = False

            for d in gitFolders:
                if d['folderName'] == folderName:
                    found = True
                    break

            if not found:
                gitFolders.append({ "folderName": folderName, "hash": "", "dir": neededDir })

    for n in range(0, len(workingTreeUpdates)):
        if someDir == workingTreeUpdatesDirs[n]:
            x = workingTreeUpdates[n].rfind("/")

            if x < 0:
                fileName = workingTreeUpdates[n]
                relpath = fileName
            else:
                fileName = workingTreeUpdates[n][x+1:]
                relpath = workingTreeUpdates[n]
            
            found = False

            for f in gitFiles:
                if fileName == f['fileName'] and relpath == f['relpath']:
                    found = True
            
            if not found:
                gitFiles.append({ "fileName": fileName, "hash": None, "relpath": relpath })

    gitFiles = [f for f in gitFiles if f['relpath'] not in workingTreeDeletes]

    for f in gitFiles:
        if f['fileName'][0] != ".":
            found = None
            for c in folderContents['folderContents']:
                if c['fileType'] != 'subfolder':
                    if c['fileName'] == f['fileName']:
                        found = c['custom']
                        f['fileId'] = c['fileId']
                        break
            
            if not 'fileId' in f or f['hash'] != found or f['relpath'] in workingTreeUpdates or overrideChanged(f['relpath']):
                if not 'fileId' in f:
                    id = None
                else:
                    id = f['fileId']

                uploadFile(f"{someDir}/{f['fileName']}", id, parentId, f['hash'], found)
    
    for n in range(0, len(workingTreeDeletes)):
        if someDir == workingTreeDeletesDirs[n]:
            relpath = workingTreeDeletes[n]

            x = relpath.rfind("/")

            if x < 0:
                fileName = relpath
            else:
                fileName = relpath[x+1:]

            for c in folderContents['folderContents']:
                if c['fileType'] != 'subfolder' and c['fileName'] == fileName:
                    deleteFile(c['fileId'], fileName)
                    break

    for d in gitFolders:
        if d['folderName'][0] != ".":
            found = None
            for c in folderContents['folderContents']:
                if c['fileType'] == 'subfolder':
                    if c['fileName'] == d['folderName']:
                        found = c['custom']
                        d['folderId'] = c['fileId']
                        break
            
            if not 'folderId' in d:
                id = None

                id = createDir(f"{someDir}/{d['folderName']}", id, parentId, d['hash'])

                doDir(f"{someDir}/{d['folderName']}", id, d['hash'])
            else:
                print(d['dir'])

                #if d['dir'] in neededDirs:
                doDir(f"{someDir}/{d['folderName']}", d['folderId'], d['hash'])

                if d['hash'] != found or overrideChanged(d['dir']):
                    updateDir(f"{someDir}/{d['folderName']}", d['folderId'], parentId, d['hash'])


cmdline = f"git log -n 1 --format='%T' -- ."

rsltGitLog = subprocess.run([cmdline], shell=True, cwd=dir, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if rsltGitLog.returncode:
    print(rsltGitLog.stdout)
    print(rsltGitLog.stderr)
    sys.exit(f"git log returned {rsltGitLog.returncode}")

outGitLog = rsltGitLog.stdout.decode(encoding='utf-8').splitlines()

commitHash = outGitLog[0]

# cmdline = "/bin/bash -c 'comm -23 <(git ls-files -o -m --exclude-standard | sort) <(git ls-files -d | sort)'"
# --no-renames: a moved file must show up as deleted (old place) and added (new place), not as "R"
cmdline = f"git -C '{dir}' status -s --no-renames -- ."

rsltWorkTree = subprocess.run([cmdline], shell=True, cwd=dir, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if rsltWorkTree.returncode:
    print(rsltWorkTree.stdout)
    print(rsltWorkTree.stderr)
    sys.exit(f"ls-files returned {rsltWorkTree.returncode}")

outWorkTree = rsltWorkTree.stdout.decode(encoding='utf-8').splitlines()

workingTreeUpdates = []
workingTreeDeletes = []

for line in outWorkTree:
    status = line[:2]
    path = line[3:]

    if "D" in status:
        workingTreeDeletes.append(path)
    elif "A" in status or "M" in status:
        workingTreeUpdates.append(path)

neededDirs = []

def computeDirsList(paths):
    result = []

    for f in paths:
        parts = f.split('/')

        combinedParts = ""

        for n in range(0, len(parts)-1):
            if combinedParts == "":
                combinedParts = parts[n]
            else:
                combinedParts = f"{combinedParts}/{parts[n]}"

            if not combinedParts in neededDirs:
                neededDirs.append(combinedParts)

        if (combinedParts == ""):
            result.append(f"{dir}")
        else:
            result.append(f"{dir}/{combinedParts}")

    return result

workingTreeUpdatesDirs = computeDirsList(workingTreeUpdates)
workingTreeDeletesDirs = computeDirsList(workingTreeDeletes)

#print(workingTreeUpdatesDirs)
#print(workingTreeDeletesDirs)

#print(neededDirs)

respget = MyRequests.get(f"/LWWAPI/Admin/folders/PE000000")

if respget.status_code == 404:
    data = {}
    data['folderId'] = "PE000000"
    data['parentFolderId'] = "ROOT"
    data['folderName'] = "petshop"
    data['path'] = f"/petshop"
    data['generateId'] = "N"
    data['defaultTran'] = "PE01"

    if Globals.myDebug > 0:
        print(f"{data['folderId']} {data['folderName']}")

    resppost = MyRequests.post("/LWWAPI/Admin/folders", data)

    if (resppost.status_code >= 400):
        raise Exception('status code ' + str(resppost.status_code))

    if Globals.myDebug > 0:
        print(f"\n{resppost.status_code} {resppost.text}")



doDir(dir, "PE000000", "")