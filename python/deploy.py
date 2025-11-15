from jinja2 import Template
from pathlib import Path
import sys
import os
import tempfile

template_src = '''//DEPLOY   JOB 'DEPLOY',CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID
//*
//      EXPORT SYMLIST=*
//         SET LWZMHLQ=YINSYS.LWZM020
//      JCLLIB ORDER=(&LWZMHLQ..JCL)
//*
//ZMAKE   EXEC PROC=ISPFMAKE,
//             LWZMHLQ=&LWZMHLQ,
//             MAKEPARM='-t {{ target }}',
//             EXECLIB=&LWZMHLQ..EXEC,
//             DYNAMNBR.ZMAKE=100
//ZMAKE.LWZMINP DD *,SYMBOLS=EXECSYS
.USSHOME = {{ homedir }}
version := {{ version }}
env     := {{ env }}
envl    := {{ envl }}
srchlq  := {{ srchlq }}.{{ version }}
tgthlq  := {{ tgthlq }}.{{ env }}
gitdir  := {{ gitdir }}
cicshlq := {{ cicshlq }}

{{ zmake_file }}'''

jcl_template = Template(template_src)

with open("ZMAKE/DEPLOY.zmake", "r") as file:
    zmake_file = file.read()

data = {
    "target": "DEPLOY_ALL",
    "homedir": Path.home(),
    "srchlq": f"{os.getlogin()}.PETSHOP",
    "tgthlq": f"{os.getlogin()}.PETSHOP",
    "version": "V1",
    "env": "DEV1",
    "envl": "dev1",
    "gitdir": os.getcwd(),
    "cicshlq": "DFH620",
    "zmake_file": zmake_file
}

if len(sys.argv) == 2:
    data["target"] = sys.argv[1]
else:
    data["target"] = "DEPLOY_ALL"

jcl = jcl_template.render(data)

temp = tempfile.NamedTemporaryFile()

with open(temp.name, "w") as file:
    file.write(jcl)

os.system(f"submit {temp.name}")
