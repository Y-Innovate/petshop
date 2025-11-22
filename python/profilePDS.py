import sys
import yaml
from jinja2 import Template, Environment, BaseLoader
from zoautil_py import datasets

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

for line in memberContents.splitlines():
    datasets.write(f'{tgtpds}({member})', line[:72].rstrip(), append=append)
    append = True