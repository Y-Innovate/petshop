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
petdb   := {{ petdb }}
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
    "tgthlq": "YINCIC.CPSM.CIC3WB01.PET",
    "version": "V1",
    "env": "DEV1",
    "envl": "dev1",
    "petdb": "D1",
    "gitdir": os.getcwd(),
    "cicshlq": "CICS62",
    "zmake_file": zmake_file
}

if len(sys.argv) > 1:
    data["target"] = sys.argv[1]
if len(sys.argv) > 2:
    data["env"] = sys.argv[2].upper()
    data["envl"] = sys.argv[2].lower()

jcl = jcl_template.render(data)

temp = tempfile.NamedTemporaryFile()

with open(temp.name, "w") as file:
    file.write(jcl)

os.system(f"submit {temp.name}")
