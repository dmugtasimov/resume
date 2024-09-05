#!/usr/bin/env python3

import sys
import re


TITLE_RE = re.compile(r'^#+ +\S+')
ITEM_RE = re.compile(r'(^\s*- \S)')


def main():
    prev_item_ident = None
    is_prev_title = False
    for line in sys.stdin:
        is_title = bool(TITLE_RE.match(line))
        item_match = ITEM_RE.match(line)
        if item_match:
            item_ident = len(item_match.group(1)) - 1
        elif len(line) - len(line.lstrip()) == prev_item_ident:
            item_ident = prev_item_ident
        else:
            item_ident = None

        if not line.strip() and (is_prev_title or prev_item_ident):
            continue

        if prev_item_ident and not item_ident:
            print()  # restore last empty line

        line = line.replace('♥', '`')
        print(line, end='')
        is_prev_title = is_title
        prev_item_ident = item_ident


if __name__ == '__main__':
    main()
