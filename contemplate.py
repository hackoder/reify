import argparse
import os
import select
import string
import sys

import yaml
import jinja2


def have_stdin():
    return select.select([sys.stdin, ], [], [], 0.0)[0]


def parse_envfile(env, envfile):
    for line in envfile:
        if line[0] == '#':
            continue
        line = string.Template(line.strip()).substitute(env)
        left, _, right = line.partition('=')
        env[left] = right


def parse_yamlfile(stream):
    ctx = yaml.safe_load(stream)
    if not ctx:
        return {}
    if isinstance(ctx, dict):
        return ctx
    raise Exception('could not load dict from yaml in {}'.format(stream.name))


def get_parser():
    parser = argparse.ArgumentParser(description='render a jinja2 template')
    parser.add_argument(
        'template',
        type=argparse.FileType('r'),
        help='the template file',
    )
    parser.add_argument(
        '--context', '-c',
        type=argparse.FileType('r'),
        help='file to load context data from',
    )
    parser.add_argument(
        '--envfile', '-e',
        type=argparse.FileType('r'),
        help='file with environment varibles',
    )

    return parser


def main():
    parser = get_parser()
    args = parser.parse_args()

    template = jinja2.Template(args.template.read())
    context = {'env': os.environ.copy()}

    if args.envfile:
        parse_envfile(context['env'], args.envfile)

    if have_stdin():
        context.update(parse_yamlfile(sys.stdin))

    if args.context:
        context.update(parse_yamlfile(args.context))

    print(template.render(context))


if __name__ == '__main__':
    main()
