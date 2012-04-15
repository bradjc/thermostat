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

OUTPUT_DIR = 'data'

now = int(time.time())

# dict of all the users and the line counts
data = {}

user_lines = {}

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

# Find all the .tex files and add them to the git log call
for dirpath, dirname, filenames in os.walk(PAPERS_DIR):
    print dirpath
    print filenames

    # search for .tex files
    is_tex = False
    for f in filenames:
        name, ext = os.path.splitext(f)
        if ext == '.tex':
            is_tex = True
            break

    # Check that this isn't a template
    if 'template' in dirpath:
        continue

    if is_tex:
        command.append('--')
        command.append(dirpath + '/*.tex')


cmd = ' '.join(command)
git = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
out, err = git.communicate()


lines = out.split('\n')

username = ''
time     = ''
lc       = 0 # line count
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



tof = open(OUTPUT_DIR + '/lines_changed_total.data', 'w')
tof.write('username lines\n')

plt_bf = open(GNUPLOT_PLT_BASE, 'r')
plt_of = open(OUTPUT_DIR + '/' + GNUPLOT_PLT_OUT, 'w')
plt  = plt_bf.read()
plt_bf.close()
plt  += '\n\nplot '
i    = 0
for uname in sorted(data):

    gof = open(OUTPUT_DIR + '/lines_changed_graph_' + uname + '.data', 'w')
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
    user_lines[uname] = total

    # Update gnuplot script
    plt += "'" + OUTPUT_DIR + "/lines_changed_graph_" + uname + ".data' " \
           "using 1:2 " \
           "with lines " \
           "ls " + str(i+1) + " " \
           "title '" + uname + "'" \
           ", \\\n"


    i += 1

plt_of.write(plt[:-4])

tof.close()
plt_of.close()



# Run gnuplot
gnuplot_cmd = ['gnuplot', OUTPUT_DIR + '/' + GNUPLOT_PLT_OUT]

gnup = subprocess.Popen(gnuplot_cmd, stdout=subprocess.PIPE)
out, err = gnup.communicate()

convert_cmd = ['convert', '-quality', '300', 'lines.eps', 'lines.png']
conv = subprocess.Popen(convert_cmd, stdout=subprocess.PIPE)
out, err = conv.communicate()


# Make the total lines table
ul = open('user_lines.html', 'w')
#for uname, lines in sorted(user_lines.iteritems(), key=lambda (k,v): (v,k)):
for uname in sorted(user_lines, key=user_lines.get, reverse=True):
    ul.write('<tr><td>' + uname + '</td><td>' + str(user_lines[uname]) + '</td></tr>')

ul.close()

