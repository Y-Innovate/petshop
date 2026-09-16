import sys
import yaml
from jinja2 import Template, Environment, BaseLoader
from zoautil_py import datasets
from zoautil_py.zoau_io import zopen

srcpds = sys.argv[1]
tgtpds = sys.argv[2]
member = sys.argv[3]
envfile = sys.argv[4]

with open(envfile, 'r') as prfl:
    prfl = yaml.safe_load(prfl)

templateContents = datasets.read(f'{srcpds}({member})')
template = Template(templateContents)
template2 = Environment(loader=BaseLoader).from_string(template.render(prfl))

memberContents = template2.render(prfl)

append = False

lines = memberContents.splitlines()

with zopen(f"//'{tgtpds}({member})'", 'w', 'cp037') as tgtmem:
    for line in lines:
        tgtmem.write(line[:80].ljust(80))
