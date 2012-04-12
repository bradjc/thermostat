#!/usr/bin/python
"""
Display lines of code modified grouped into days.  Pass path in if desired.
"""

import subprocess
import re
import sys
import os
import time
from datetime import datetime


PAPERS_DIR = '/Users/bradjc/git/shed/papers'

# Time in seconds to graph lines
WINDOW = 60*60*24*31

GNUPLOT_PLT_OUT  = 'plot_lines.plt'
GNUPLOT_PLT_BASE = 'plot_lines_base.plt'

now = int(time.time())

command = ["cd", PAPERS_DIR, "&&"
           "git", "log",
           "--ignore-space-change",
           "--ignore-all-space",
           "--patience",
           "--no-color",
           "--pretty='%ae %ct'",
           "--diff-filter=AMD",
           "--find-copies-harder",
           "-l10",
           "--numstat"
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

    # Check that this isn't a template
    if 'template' in dirpath:
        continue

    if tex:
        command.append('--')
        command.append(dirpath + '/*.tex')
    #    break

print command
cmd = ' '.join(command)
git = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
print git
out, err = git.communicate()
print out

lines = out.split('\n')


data = {}

username = ''
time = ''
lc = 0 # line count
for l in lines:
    if '@' in l:
        if not username == '':
            # save previous
            if username not in data:
                data[username] = []
            data[username].append(tuple([time, lc]))

        record = l.split(' ')
        username = record[0].split('@')[0]
        time = int(record[1])
        lc = 0

    else:
        record = l.split()
        if len(record) == 0:
            continue
    #    lc += int(record[0]) + int(record[1])
        lc += int(record[0])




print data


tof = open('lines_changed_total.data', 'w')
tof.write('username lines\n')

plt_bf = open(GNUPLOT_PLT_BASE, 'r')
plt_of = open(GNUPLOT_PLT_OUT, 'w')
plt  = plt_bf.read()
plt_bf.close()
plt  += '\n\nplot '
i    = 0
for uname in sorted(data):

    gof = open('lines_changed_graph_' + uname + '.data', 'w')
    gof.write('timestamp lines\n')

    sd = sorted(data[uname], key=lambda data: data[0])


    cumsum = 0
    total  = 0
    for dp in sd:
        time = dp[0]
        lc   = dp[1]

        total += lc

        if (now - WINDOW < time):
            cumsum += lc
            outs = ''
            outs += str(time) + ' ' + str(cumsum) + '\n'
            gof.write(outs)

    gof.close()

    # Save total
    tof.write(uname + ' ' + str(total) + '\n')

    # Update gnuplot script
    plt += "'lines_changed_graph_" + uname + ".data' " \
           "using 1:2 " \
           "with lines " \
           "ls " + str(i+1) + " " \
           "title '" + uname + "'" \
           ", \\\n"


    i += 1

plt_of.write(plt[:-4])

tof.close()
plt_of.close()







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
