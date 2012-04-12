#!/usr/bin/python
"""
Display lines of code modified grouped into days.  Pass path in if desired.
"""

import subprocess
import re
import sys
import os
from datetime import datetime


PAPERS_DIR = '.'

command = ["git", "log",
           "--ignore-space-change",
"--ignore-all-space",
"--patience",
"--no-color",
"--pretty=%ae %ct",
"--diff-filter=AMD",
"--find-copies-harder",
"-l10",
"numstat"
]

total_files, inserted_t, deleted_t = 0, 0, 0


for dirpath, dirname, filenames in os.walk(PAPERS_DIR):
    print dirpath
    print filenames

# search for .tex files
    tex = False
    for f in filenames:
        name, ext = os.path.splitext(f)
        if ext == '.tex':
            tex = True
            break

    if tex:
        command.append('--')
        command.append(dirpath)

print command


"""
def outputline(date, changes):
    global total_files, inserted_t, deleted_t
    if not date: return
    print "%s |% 7d lines | (%d)" % (date.strftime("%a, %b %d %Y"), changes, inserted_t + deleted_t)
    sys.stdout.flush()

def main(argv):
    global total_files, inserted_t, deleted_t
    if len(argv) > 1:
        command.append("--")
        command.extend(argv[1:])
    #print ' '.join(command)  # DEBUG
    git = subprocess.Popen(command, stdout=subprocess.PIPE)
    out, err = git.communicate()
    curr_day = None
    days_changes = 0
    for line in out.split('\n'):
        if not line: continue
        if line[0] != ' ':
            # This is a description line
            timestamp = datetime.fromtimestamp(float(line.strip()))
            day = datetime.date(timestamp)
        else:
            # This is a stat line
            data = re.findall(
                ' (\d+) files changed, (\d+) insertions\(\+\), (\d+) deletions\(-\)',
                line)
            files, insertions, deletions = ( int(x) for x in data[0] )

            if day != curr_day:
                outputline(curr_day, days_changes)
                days_changes = 0
                curr_day = day

            total_files += files
            inserted_t += insertions
            deleted_t += deletions
            days_changes += insertions + deletions
    outputline(curr_day, days_changes)
if __name__ == '__main__':
    sys.exit(main(sys.argv))

"""
