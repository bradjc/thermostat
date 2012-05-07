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

MAX_LINE_COUNT_PER_COMMIT = 1000

PAPERS_DIR = '/home/bradjc/git/shed/papers'

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


# Run log call with all .tex files listed
cmd = ' '.join(command)
git = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
out, err = git.communicate()
print out
lines = out.split('\n')

# Iterate through all results and group by username
username = ''
time	 = ''
lc		 = 0 # line count
for l in lines:
	if '@' in l:
		if not username == '' and lc < MAX_LINE_COUNT_PER_COMMIT:
			# save previous
			if username not in data:
				data[username] = []
			data[username].append(tuple([time, lc]))

		record	 = l.split(' ')
		username = record[0].split('@')[0]
		time	 = int(record[1])
		lc		 = 0

	else:
		record = l.split()
		if len(record) == 0:
			continue

		lc += int(record[0])



tof = open(OUTPUT_DIR + '/lines_changed_total.data', 'w')
tof.write('username lines\n')

# Create gnuplot script
plt_bf = open(GNUPLOT_PLT_BASE, 'r')
plt_of = open(OUTPUT_DIR + '/' + GNUPLOT_PLT_OUT, 'w')
plt  = plt_bf.read()
plt_bf.close()
plt  += '\n\nplot '
i	 = 0
for uname in sorted(data):

	gof = open(OUTPUT_DIR + '/lines_changed_graph_' + uname + '.data', 'w')
	gof.write('timestamp lines\n')

	sd = sorted(data[uname], key=lambda data: data[0])


	cumsum = 0
	total  = 0
	for dp in sd:
		time = dp[0]
		lc	 = dp[1]

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
		  # "ls " + str(i+1) + " " \
	plt += "'" + OUTPUT_DIR + "/lines_changed_graph_" + uname + ".data' " \
		   "using 1:2 " \
		   "with lines " \
		   "lw 10 " \
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


# Make the Commit Log listing

# get the base html
commit_html_f = open('commit_entry_base.html', 'r')
base_html = commit_html_f.read()
commit_html_f.close()

# output file
commit_list_f = open('commit_list.html', 'w')

# get commit log
git_log_cmd = ["cd", PAPERS_DIR, "&&"
		   "git", "log",
		   "-n 10",
		   "--no-color",
		   "--pretty='%ae %ct %s'"
		  ]
cmd = ' '.join(git_log_cmd)
git = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
out, err = git.communicate()

#iterate commit log
lines  = out.split('\n')
author = ''
date   = ''
commit = ''
for l in lines:

	record = l.split(' ', 2)
	if len(record) < 3:
		continue
	author = record[0].split('@')[0]
	date   = datetime.fromtimestamp(int(record[1])).strftime('%d/%m/%y %I:%M %p')
	commit = record[2]

	# write output
	new_entry = base_html
	new_entry = new_entry.replace('[USERNAME]', author)
	new_entry = new_entry.replace('[DATE]', date)
	new_entry = new_entry.replace('[COMMIT]', commit)
	commit_list_f.write(new_entry)


commit_list_f.close()








