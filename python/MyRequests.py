import json

from Globals import Globals

class MyRequests:
    @classmethod
    def getBearerToken(cls, uri):
        data = {}
        data["username"] = Globals.myCreds[0]
        data["password"] = Globals.myCreds[1]

        requrl = Globals.myHost + uri

        print("POST " + requrl)

        resppost = Globals.s.post(requrl, data=json.dumps(data))

        if (resppost.status_code == 200):
            print(resppost.text)
            gettoken = json.loads(resppost.text)

            if (gettoken['token']):
                Globals.myBearer = gettoken['token']
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
            headers = {'Authorization': f"Bearer {Globals.myBearer}"}

            if data != None:
                resp = Globals.s.request(method, requrl, headers=headers, data=datajson, verify="testAPI_truststore.crt")
            else:
                if files != None:
                    resp = Globals.s.request(method, requrl, headers=headers, files=files, verify="testAPI_truststore.crt")
                else:
                    resp = Globals.s.request(method, requrl, headers=headers, verify="testAPI_truststore.crt")
        else:
            if data != None:
                resp = Globals.s.request(method, requrl, auth=Globals.myCreds, data=datajson, verify="testAPI_truststore.crt")
            else:
                if files != None:
                    resp = Globals.s.request(method, requrl, auth=Globals.myCreds, files=files, verify="testAPI_truststore.crt")
                else:
                    resp = Globals.s.request(method, requrl, auth=Globals.myCreds, verify="testAPI_truststore.crt")
        
        return resp

    @classmethod
    def get(cls, requrl, data = None):
        _requrl = Globals.myHost + requrl

        print("GET " + _requrl)

        respget = cls.doit("GET", _requrl, data)
        
        return respget

    @classmethod
    def put(cls, requrl, data = None, files = None):
        _requrl = Globals.myHost + requrl

        print("PUT " + _requrl)

        respput = cls.doit("PUT", _requrl, data, files)
        
        return respput

    @classmethod
    def post(cls, requrl, data = None, files = None):
        _requrl = Globals.myHost + requrl

        print("POST " + _requrl)

        resppost = cls.doit("POST", _requrl, data, files)
        
        return resppost

    @classmethod
    def delete(cls, requrl, data = None):
        _requrl = Globals.myHost + requrl

        print("DELETE " + _requrl)

        respdelete = cls.doit("DELETE", _requrl, data)

        return respdelete