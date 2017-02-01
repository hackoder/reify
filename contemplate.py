import os
import sys
import yaml
import jinja2

if len(sys.argv) < 2:
    sys.stderr.write('No template path\n')
    sys.exit(1)

template_path = sys.argv[1]

try:
    with open(template_path) as f:
        template = jinja2.Template(f.read())
except Exception as e:
    sys.stderr.write(
        'Could not read template "{}".\n{}\n'.format(template_path, e))
    sys.exit(1)

try:
    context = yaml.safe_load(sys.stdin)
except Exception as e:
    sys.stderr.write('Could not parse yaml context from stdin.\n{}\n'.format(e))
    sys.exit(1)

print(template.render(context))
