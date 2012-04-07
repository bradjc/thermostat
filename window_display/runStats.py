#!/usr/bin/env python

import sys
import os
import lxml.etree as le
from bs4 import BeautifulSoup
"""
print 'Updating SVN repo'
os.system('cd papers; svn up')

print 'Running XML export from SVN repo'
os.system('cd papers; svn log -v --xml > logfile.log')

listToExclude = []
with open('exclude-list.txt', 'r') as f:
	listToExclude = map(lambda x: x.strip(), f.readlines())

print 'Exclude list: ' ,
print listToExclude	

doc = le.parse('papers/logfile.log')
elementsToRemove = []
for pat in listToExclude:
	for elt in doc.findall('logentry[@revision=\'' + pat + '\']'):
		print 'Removing element...'
		elt.getparent().remove(elt)

print 'Writing fille back to disk...'
with open('papers/logfile.log', 'w') as f:
	f.write(le.tostring(doc))

print 'Invoking graph generation software...'
os.system('java -jar statsvn.jar papers/logfile.log papers -include "**/*.tex:*Makefile*" -config-file config.txt')

"""

print 'Generating output HTML...'

def getSoup(fileName):
	with open(fileName, 'r') as f:
		return BeautifulSoup(f.read())

template = ''
with open('template.html', 'r') as f:
	template = f.read()

template2 = ''
with open('template2.html', 'r') as f:
	template2 = f.read()

developers = getSoup('developers.html') 
index = getSoup('index.html') 
clog = getSoup('commitlog.html') 
		
authorTable = developers.html.body.table
template = template.replace('[A]', str(authorTable))

tagCloud = index.html.body.findAll('div')[2].p
template = template.replace('[T]', str(tagCloud))
template2 = template2.replace('[T]', str(tagCloud))

commitList = clog.html.body.findAll('dl')[1]
for i in range(24,len(commitList.contents)):
	commitList.contents[len(commitList.contents) - 1].extract()
template = template.replace('[C]', str(commitList))
template2 = template2.replace('[C]', str(commitList))

with open('output.html', 'w') as f:
	f.write(template)

with open('output2.html', 'w') as f:
	f.write(template2)
