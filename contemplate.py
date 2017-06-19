import os
import sys
import yaml
import jinja2
import select
import argparse


def have_stdin():
    return select.select([sys.stdin, ], [], [], 0.0)[0]


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
    return parser


def main():
    parser = get_parser()
    args = parser.parse_args()

    template = jinja2.Template(args.template.read())
    context = {'env': os.environ.copy()}

    if have_stdin():
        context.update(yaml.safe_load(sys.stdin))

    if args.context:
        context.update(yaml.safe_load(args.context))

    print(template.render(context))


if __name__ == '__main__':
    main()
