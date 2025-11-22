import sys
import yaml
from jinja2 import Environment, FileSystemLoader, BaseLoader

templatedir = sys.argv[1]
templatename = sys.argv[2]
envfile = sys.argv[3]

with open(envfile, 'r') as prfl:
    prfl = yaml.safe_load(prfl)

environment = Environment(loader=FileSystemLoader(templatedir))
template = environment.get_template(templatename)
template2 = Environment(loader=BaseLoader).from_string(template.render(prfl))
print(template2.render(prfl))