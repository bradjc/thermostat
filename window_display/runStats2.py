






















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

usageCode = ''
with open('usage.html', 'r') as f:
	usageCode = f.read()

template2 = template2.replace('[USAGE]', usageCode)

with open('output.html', 'w') as f:
	f.write(template)

with open('output2.html', 'w') as f:
	f.write(template2)
