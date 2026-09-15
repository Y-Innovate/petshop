import copy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'vendor'))

from ruamel.yaml import YAML

BASE_FILE = 'openapi/petshop.yaml'
OTHER_FILE = 'openapi/petshop_2.yaml'
OUTPUT_FILE = 'openapi/petshop_combined.yaml'

yaml = YAML()
yaml.preserve_quotes = True
yaml.width = 4096


def load(path):
    with open(path) as f:
        return yaml.load(f)


def unescape_pointer_token(token):
    return token.replace('~1', '/').replace('~0', '~')


def resolve_pointer(root, pointer_path):
    node = root
    if pointer_path == '':
        return node
    for token in pointer_path.split('/'):
        token = unescape_pointer_token(token)
        node = node[int(token)] if isinstance(node, list) else node[token]
    return node


def split_ref(ref):
    filename, _, pointer_path = ref.partition('/')
    return filename, pointer_path


def is_bare_ref(value):
    return isinstance(value, dict) and set(value.keys()) == {'$ref'} and isinstance(value['$ref'], str)


def resolve_lww_refs(node, files):
    """Replace every $ref found directly under an x-LWWProcessingSteps key
    with the equivalent node resolved from the referenced file."""
    if isinstance(node, dict):
        for key, value in node.items():
            if key == 'x-LWWProcessingSteps' and is_bare_ref(value):
                filename, pointer_path = split_ref(value['$ref'])
                resolved = resolve_pointer(files[filename], pointer_path)
                node[key] = copy.deepcopy(resolved)
                resolve_lww_refs(node[key], files)
            else:
                resolve_lww_refs(value, files)
    elif isinstance(node, list):
        for item in node:
            resolve_lww_refs(item, files)


def strip_file_from_refs(node):
    """For every remaining $ref, replace a leading file name with '#'."""
    if isinstance(node, dict):
        for key, value in node.items():
            if key == '$ref' and isinstance(value, str):
                filename, pointer_path = split_ref(value)
                if filename != '#':
                    node[key] = f'#/{pointer_path}'
            else:
                strip_file_from_refs(value)
    elif isinstance(node, list):
        for item in node:
            strip_file_from_refs(item)


def main():
    base = load(BASE_FILE)
    other = load(OTHER_FILE)
    files = {BASE_FILE.rsplit('/', 1)[-1]: base, OTHER_FILE.rsplit('/', 1)[-1]: other}

    resolve_lww_refs(base, files)
    strip_file_from_refs(base)
    base['components']['x-ioareas'] = copy.deepcopy(other['components']['x-ioareas'])

    with open(OUTPUT_FILE, 'w') as f:
        yaml.dump(base, f)


if __name__ == '__main__':
    main()
