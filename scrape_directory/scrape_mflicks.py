from bs4 import BeautifulSoup

directory = BeautifulSoup(open("mflicks_dir.html"))


for link in directory.find_all('a'):
#	if link['class'] == 'email':
	try:
		if str(link.attrs['class'][0]) == 'email':
			print link.contents[0]
	except:
		pass

