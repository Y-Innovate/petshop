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

Globals.myHost = "https://yinhdisv:8081"
#Globals.myHost = "https://mainframeyin:8092"
Globals.myBasepath = ""
Globals.myCreds = ('','')
Globals.s = requests.sessions.Session()

if Globals.myCreds[0] == '':
    userid = input("Give your userid: ")
    Globals.myCreds = (userid,'')

if Globals.myCreds[1] == '':
    passwd = getpass("Give your password: ")
    Globals.myCreds = (Globals.myCreds[0], passwd)

print("Getting bearer token")

MyRequests.getBearerToken("/LWWAPI/API/token")

dir = "/home/bobby/Y-Innovate/software/git/petshop/ui"

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

def createDir(someDir, id, parentId, custom):
    global dir

    n = len(dir)

    print(f"Create dir {someDir[n+1:]}")

    x = re.search(".*\\/([^\\/]*)$", someDir)

    data = {}
    data['folderId'] = ""
    data['parentFolderId'] = parentId
    data['folderName'] = x.group(1)
    data['path'] = f"/petshop/{someDir[n:]}"
    data['generateId'] = "Y"
    data['defaultTran'] = ""
    data['defaultWebpageId'] = ""
    data['custom'] = custom

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
    data['defaultTran'] = ""
    data['defaultWebpageId'] = ""
    data['custom'] = custom

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
        if (x.group(1) == "js"):
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

        #print(f"#{found}# #{calculatedHash}#")
        if calculatedHash == found:
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
    newFile['transaction'] = ""
    newFile['preventCache'] = "N"
    newFile['storeBinary'] = "Y"
    newFile['scriptLoadModule'] = ""
    newFile['preexecLoadModule'] = ""
    newFile['postexecLoadModule'] = ""
    newFile['whereStoreImage'] = ""
    newFile['templateName'] = ""
    newFile['DDName'] = ""
    newFile['member'] = ""
    newFile['custom'] = _custom

    if (os.path.isfile(f"{x.group(1)}.{x.group(2)}")):
        with open(f"{x.group(1)}.{x.group(2)}",'r') as overrideFile:
            overrides = yaml.safe_load(overrideFile)

            for x in overrides['newFile']:
                newFile[x] = overrides['newFile'][x]

    resppost = MyRequests.post("/LWWAPI/Admin/files", None, {'jsondata': (None, json.dumps(newFile)), 'contents': (None, fileContentsB64)})

    if resppost.status_code >= 400:
        raise Exception(f'status code {str(resppost.status_code)} {resppost.text}')

    if Globals.myDebug > 0:
        print(f"{resppost.status_code} {resppost.text}")

def doDir(someDir, parentId, folderHash):
    global commitHash
    global dir
    global workingTreeUpdates
    global workingTreeUpdatesDirs
    global neededDirs

    respget = MyRequests.get(f"/LWWAPI/Admin/files?folderId={parentId}")

    if respget.status_code != 200:
        raise Exception(f"{respget.status_code} {respget.text}")
    
    folderContents = json.loads(respget.text)
    
    #print(folderContents)

    cmdline = f"git -C '{someDir}' ls-tree -t {commitHash}"

    #print(cmdline)

    rsltGitLsTree = subprocess.run([cmdline], shell=True, cwd=someDir, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if rsltGitLsTree.returncode:
        print(rsltGitLsTree.stdout)
        print(rsltGitLsTree.stderr)
        sys.exit(f"git ls-tree returned {rsltGitLsTree.returncode}")

    outGitLsTree = rsltGitLsTree.stdout.decode(encoding='utf-8').splitlines()

    gitFiles = []
    gitFolders = []

    # print(outGitLsTree)

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

    # print(gitFiles)

    for f in gitFiles:
        if f['fileName'][0] != ".":
            found = None
            for c in folderContents['folderContents']:
                if c['fileType'] != 'subfolder':
                    if c['fileName'] == f['fileName']:
                        found = c['custom']
                        f['fileId'] = c['fileId']
                        break
            
            if not 'fileId' in f or f['hash'] != found or f['relpath'] in workingTreeUpdates:
                if not 'fileId' in f:
                    # id = nextFileId()
                    id = None
                else:
                    id = f['fileId']

                uploadFile(f"{someDir}/{f['fileName']}", id, parentId, f['hash'], found)
    
    # print(gitFolders)

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
                # id = nextFileId()
                id = None

                id = createDir(f"{someDir}/{d['folderName']}", id, parentId, d['hash'])

                doDir(f"{someDir}/{d['folderName']}", id, d['hash'])
            else:
                # print(d['dir'])

                #if d['dir'] in neededDirs:
                doDir(f"{someDir}/{d['folderName']}", d['folderId'], d['hash'])

                if d['hash'] != found:
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
cmdline = f"git -C '{dir}' status -s -- . | egrep '^[A|M] ' | cut -c 4-"

rsltWorkTree = subprocess.run([cmdline], shell=True, cwd=dir, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if rsltWorkTree.returncode:
    print(rsltWorkTree.stdout)
    print(rsltWorkTree.stderr)
    sys.exit(f"ls-files returned {rsltWorkTree.returncode}")

workingTreeUpdates = rsltWorkTree.stdout.decode(encoding='utf-8').splitlines()
workingTreeUpdatesDirs = []

#print(workingTreeUpdates)

neededDirs = []

for m in range(0, len(workingTreeUpdates)):
    f = workingTreeUpdates[m]

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
        workingTreeUpdatesDirs.append(f"{dir}")
    else:
        workingTreeUpdatesDirs.append(f"{dir}/{combinedParts}")

#print(workingTreeUpdatesDirs)

#print(neededDirs)

doDir(dir, "OcQhUo", "")