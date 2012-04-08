#!/usr/bin/env python

import sys
import os
import lxml.etree as le
from bs4 import BeautifulSoup
import time



PAPER_DIR  = '~/svn/shed/papers'
THIS_DIR   = os.getcwd()
OUTPUT_DIR = 'svnstat'

def getSoup(fileName):
	with open(fileName, 'r') as f:
		text = f.read().replace('charset=ISO-8859-1"', 'charset=utf-8"')
		return BeautifulSoup(text)

developers = ''

now   = time.time()
nowg  = time.gmtime(now+86400)
befg  = time.gmtime(now-2629743.83)
start = time.strftime('%Y-%m-%d', nowg)
end   = time.strftime('%Y-%m-%d', befg)

print 'Updating SVN repo'
os.system('cd ' + PAPER_DIR + '; svn up')

for i in range(2):


	print 'Running XML export from SVN repo'
	if i == 0:
		os.system('cd ' + PAPER_DIR + '; svn log -v --xml > ' + THIS_DIR + '/logfile.log')
	elif i == 1:
		os.system('cd ' + PAPER_DIR + '; svn log -r {' + start + '}:{' + end + '} -v --xml > ' + THIS_DIR + '/logfile.log')

	listToExclude = []
	with open('exclude-list.txt', 'r') as f:
		listToExclude = map(lambda x: x.strip(), f.readlines())

	print 'Exclude list: ' ,
	print listToExclude

	doc = le.parse('logfile.log')
	elementsToRemove = []
	for pat in listToExclude:
		for elt in doc.findall('logentry[@revision=\'' + pat + '\']'):
			print 'Removing element...'
			elt.getparent().remove(elt)

	print 'Writing fille back to disk...'
	with open('logfile.log', 'w') as f:
		f.write(le.tostring(doc))

	print 'Invoking graph generation software...'
	os.system('java -mx5gb -jar statsvn.jar logfile.log ' + PAPER_DIR + ' -include "**/*.tex:*Makefile*" -config-file config.txt -output-dir ' + OUTPUT_DIR)

	if i == 0:
		developers = getSoup(OUTPUT_DIR + '/developers.html')



print 'Generating output HTML...'

#template = ''
#with open('template.html', 'r') as f:
#	template = f.read()

#developers = getSoup(OUTPUT_DIR + '/developers.html')
#index      = getSoup(OUTPUT_DIR + '/index.html')
clog       = getSoup(OUTPUT_DIR + '/commitlog.html')


authorTable = developers.html.body.table.tbody
users_dup = authorTable.findAll("a", {'class': 'author'})
users = []
use_user = True
for u in users_dup:
	if not use_user:
		use_user = True
		continue

	users.append(str(u.get_text()))
	use_user = False

lines_dup = authorTable.findAll("td")
lines = []
count = 0
for l in lines_dup:
	if count < 2:
		count += 1
	elif count == 2:
		lines.append(int(l.get_text().split(' ')[0]))
		count += 1
	else:
		count = 0


user_table = ''

for i in range(len(users)):
	user = users[i]
	line = lines[i]


	user_table += '<tr>'
	user_table += '<td>' + user + '</td>'
	user_table += '<td>' + str(line) + '</td>'
	user_table += '</tr>'

of = open('user_lines.html', 'w')
of.write(user_table)
of.close()




#print authorTable
#template = template.replace('[A]', str(authorTable))

#tagCloud = index.html.body.findAll('div')[2].p
#template = template.replace('[T]', str(tagCloud))
commitList = clog.html.body.findAll('dl')[1]
for i in range(24,len(commitList.contents)):
	commitList.contents[len(commitList.contents) - 1].extract()
with open('commitlist.html', 'w') as f:
	f.write(str(commitList))

#with open('output.html', 'w') as f:
#	f.write(template)

#with open('output2.html', 'w') as f:
#	f.write(template2)
