from jinja2 import Template
from pathlib import Path
import sys
import os
import tempfile

template_src = '''//BUILD    JOB 'BUILD',CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID
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
hlq := {{ hlq }}.{{ version }}
gitdir := {{ gitdir }}
cicshlq := {{ cicshlq }}

{{ zmake_file }}'''

jcl_template = Template(template_src)

with open("ZMAKE/BUILD.zmake", "r") as file:
    zmake_file = file.read()

data = {
    "target": "BUILD_ALL",
    "homedir": Path.home(),
    "hlq": f"{os.getlogin()}.PETSHOP",
    "version": "V1",
    "gitdir": os.getcwd(),
    "cicshlq": "DFH620",
    "zmake_file": zmake_file
}

if len(sys.argv) == 3:
    data["hlq"] = sys.argv[1]
    data["target"] = sys.argv[2]
elif len(sys.argv) == 2:
    data["target"] = sys.argv[1]
else:
    data["target"] = "BUILD_ALL"

jcl = jcl_template.render(data)

temp = tempfile.NamedTemporaryFile()

with open(temp.name, "w") as file:
    file.write(jcl)

os.system(f"submit {temp.name}")
