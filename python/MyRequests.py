import json

from Globals import Globals

class MyRequests:
    @classmethod
    def getBearerToken(cls, uri):
        Globals.uri = uri

        data = {}
        if (isinstance(Globals.myCreds, tuple)):
            data["username"] = Globals.myCreds[0]
            data["password"] = Globals.myCreds[1]
            requrl = Globals.myHost + uri
        else:
            data["client_id"] = Globals.myCreds["client_id"]
            data["client_secret"] = Globals.myCreds["client_secret"]
            data["scope"] = Globals.myCreds["scope"]
            data["grant_type"] = Globals.myCreds["grant_type"]
            requrl = Globals.uri

        if Globals.myDebug > 0:
            print("POST " + requrl)

        if (isinstance(Globals.myCreds, tuple)):
            resppost = Globals.s.post(requrl, data=json.dumps(data))
        else:
            headers = {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
            resppost = Globals.s.post(requrl, data=data, headers=headers)

        if (resppost.status_code == 200):
            if Globals.myDebug > 0:
                print(resppost.text)

            gettoken = json.loads(resppost.text)

            if ("token" in gettoken):
                Globals.myBearer = gettoken['token']
            elif ("access_token" in gettoken):
                Globals.myBearer = gettoken['access_token']
            else:
                raise Exception('unknown response')
        else:
            raise Exception('status code ' + str(resppost.status_code))
    
    @classmethod
    def doit(cls, method, requrl, data = None, files = None):
        if isinstance(data, str):
            datajson = data
        else:
            datajson = json.dumps(data)

        if Globals.myBearer != "":
            for i in range(0, 2):
                headers = {'Authorization': f"Bearer {Globals.myBearer}"}

                if data != None:
                    resp = Globals.s.request(method, requrl, headers=headers, data=datajson)
                else:
                    if files != None:
                        resp = Globals.s.request(method, requrl, headers=headers, files=files)
                    else:
                        resp = Globals.s.request(method, requrl, headers=headers)

                if resp.status_code < 400 or resp.status_code >= 500 or i > 0:
                    break
                else:
                    if Globals.myDebug > 0:
                        print(f"{resp.status_code} {resp.text}")
                    cls.getBearerToken(Globals.uri)
        else:
            if data != None:
                resp = Globals.s.request(method, requrl, auth=Globals.myCreds, data=datajson)
            else:
                if files != None:
                    resp = Globals.s.request(method, requrl, auth=Globals.myCreds, files=files)
                else:
                    resp = Globals.s.request(method, requrl, auth=Globals.myCreds)
        
        return resp

    @classmethod
    def get(cls, requrl, data = None):
        _requrl = Globals.myHost + requrl

        if Globals.myDebug > 0:
            print("GET " + _requrl)

        respget = cls.doit("GET", _requrl, data)
        
        return respget

    @classmethod
    def put(cls, requrl, data = None, files = None):
        _requrl = Globals.myHost + requrl

        if Globals.myDebug > 0:
            print("PUT " + _requrl)

        respput = cls.doit("PUT", _requrl, data, files)
        
        return respput

    @classmethod
    def post(cls, requrl, data = None, files = None):
        _requrl = Globals.myHost + requrl

        if Globals.myDebug > 0:
            print("POST " + _requrl)

        resppost = cls.doit("POST", _requrl, data, files)
        
        return resppost

    @classmethod
    def delete(cls, requrl, data = None):
        _requrl = Globals.myHost + requrl

        if Globals.myDebug > 0:
            print("DELETE " + _requrl)

        respdelete = cls.doit("DELETE", _requrl, data)

        return respdelete