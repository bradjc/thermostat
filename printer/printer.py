#!/usr/bin/python

from BeautifulSoup import BeautifulSoup
import urllib
import twitter
from time import sleep
from struct import *
import random
import socket

api = twitter.Api(consumer_key='OAicZZPAyI6QsIIr8xFXVw', consumer_secret='1U6T4P7XC6kjvJxRJzqMtOOVte9A5Quav2XD8cFw', access_token_key='429457401-bk9EdTb6sbX6PCI8trN455QenEL2ycjVg0wIp0Lv', access_token_secret='n5y56iRBfSNi4xEuiXHTd6EES2fh0eHesZIgEpyUp3w')

currentId = 0
firstRun = True
statuses = {}

class printJob:
	pass

def sendPrinterJob(pj):
	sendString = ""
	print 'pj Update type: ' + pj.update_type
	if(pj.update_type == "Job"):
		print 'Parsing job...'
		sendString = pack('B20s20sii??', 1, str(pj.userName), str(pj.fileName), pj.pages, pj.sides, pj.isDuplex, pj.isColor)
	elif(pj.update_type == "Status"):
		sendString = pack('B20s20s', 2, pj.status_type, pj.status_val)
	print sendString
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM )
	#sock.sendto("heeyyyy", ("141.212.107.218", 4001))
	sock.sendto(sendString, ("141.212.107.218", 4001))
	print 'done'

def parseJobs(soup):
	global currentId
	global firstRun
	dataTable = soup.find("table", { "id" : "data" })
	rows = dataTable.findAll('tr')
	mostRecent = rows[-1]
	cols = mostRecent.findAll('td')

	pj = printJob() 	
	pj.id = cols[0].find(text=True)
	print pj.id
	if(pj.id != currentId):
		if(firstRun):
			firstRun = False
			currentId = pj.id
			return	
		currentId = pj.id
		print 'New print job found!'
		pj.update_type = "Job"
		pj.userName = cols[2].find(text=True)
		if pj.userName == "Copy":
			# not a person printing
			return
		pj.fileName = cols[4].find(text=True)
		pj.pages = int(cols[6].find(text=True))
		pj.sides = int(cols[7].find(text=True))
		pj.isDuplex = pj.pages < pj.sides
		pj.isColor = float(str.replace(str(cols[13].find(text=True)), '%', '')) != 0.0
		print 'Printer job found:'
		print ' fileName: ' + pj.fileName  
		print ' pages: ' + str(pj.pages) 
		print ' sides: ' + str(pj.sides)
		print ' duplex: ' + str(pj.isDuplex)
		print ' isColor: ' + str(pj.isColor)
		print ' user:' + pj.userName
		sendPrinterJob(pj)

def parseErrors(soup):
	global statuses
	statusTables = soup.findAll('table', {'id' : 'statbox'})
	for table in statusTables:
		status_type = str(table.find('b').find('font', text=True).strip())
		status_val  = str(table.find('td').find('font', text=True).strip())
		
		if not (status_type in statuses):
			statuses[status_type] = ""

		if status_val == "Ready" or status_val == "Standby" or status_val == "Printing" or status_val == "Copying" or status_val == "Scanning":
			# This isn't an error
			continue
		
		if status_val != statuses[status_type]:
			# some sort of error and we haven't yet seen it
			print "error: " + status_val + ", " + status_type
			pj = printJob()
			pj.update_type = "Status"
			pj.status_val = status_val
			pj.status_type = status_type

			print 'Printer status update found:'
			print ' status_val: ' + pj.status_val
			print ' status_type: ' + pj.status_type
			sendPrinterJob(pj)
			#api.PostUpdate(createErrorTweet(error_type=status_type, error_val=status_val))
 			
		statuses[status_type] = status_val


counter = 0
while(True):
	print 'Fetching printer information...'
	try:
		soup = BeautifulSoup(urllib.urlopen('http://4908priv.eecs.umich.edu/UE/jobaccountingbrowse.html'))
		parseJobs(soup)
		#outputString = createTweet(pj.userName.strip(), pj.pages, pj.isColor, pj.isDuplex) 
		#print outputString
		#api.PostUpdate(outputString)
		soup = BeautifulSoup(urllib.urlopen('http://4908priv.eecs.umich.edu/status.html'))
		parseErrors(soup)
	except Exception as e:
		print e
		print 'failed'
	sleep(10)

def createTweet (username, pages, color, double_sided):
	if len(username) > 20:
		username = username[0:16] + "..."	
	
	if username == "_":
		tweets = [	"Ugh more printing? I'm probably going to crash soon.", \
					"Well, well, well now. Aren't we just a privacy printing hippie.", \
					"I don't approve of this printing nonsense. Couldn't it wait until tomorrow?", \
					"No username huh? Probably just Pat again.", \
					"Hey hacker, go find your own printer. Leave me alone!", \
					"Don't want me to know who you are? We could have been friends. Oh well.", \
					"Well there goes " + str(pages) + " perfectly good sheet" + ("", "s")[pages>1] + " of paper."]

	elif username == "Copy":
		tweets = [	"Copy? Copy?!? You want me to make copies too? I'm only one printer...", \
				"All this technology and you just want me to make a lousy copy?", \
				"Do you know how lucky you have it? Back in my day we had to train 7 monks to do this much copying." ]
		if color:
			tweets.extend( [	"Do you know how much work it is to make a color copy? Gotta fire up the scanner, warm up the black ink, all the colors..."] )
	
	else:
		random1 = random.randrange(0, 3)
		
		if random1 == 0:
			if color == False:
				tweets = [	"Really " + username + "? No color for you? What a waste of my capabilities.", \
							str(pages) + " page" + ("", "s")[pages > 1] + " of black and white sure " + ("is", "are")[pages > 1] + " boring, " + username + ".", \
							"What, is my crappy image quality not good enough for you " + username + "?", \
							"That ink isn't going to use itself. Take charge " + username + ", and print in color!"]
			
			if color == True:
				tweets = [	"Hey " + username + " did you need color? I guess I have to warm up the magenta.", \
							"My solid ink is expensive. " + username + ", this is going to cost you.", \
							"Woah " + username + ". Lay off the color will you?", \
							"That fancy color ink doesn't grow on trees you know. Save some for next time, " + username + "."]
		elif random1 == 1:
			if pages > 6:
				tweets = [	"Printing a book there " + username + "?", \
							"And " + username + " is at it again printing an entire encyclopedia.", \
							"Better check back later " + username + ". It's going to be a while.", \
							"When I'm out of paper I'll know who to blame: " + username + ".", \
							"Using " + str(pages) + " pages " + username + "? Perhaps those could have been used for somthing important."]
				
			if pages <= 6:
				tweets = [	"Making me warm up for a lousy " + str(pages) + " page job, " + username + "?", \
							"Maybe I'll print your document twice, " + username + ", because it was so short.", \
							"Hey " + username + "! Come back when you have a real print job ready.", \
							"I was built to handle some real print jobs. Not a piddly " + ("single page", str(pages) + " pages")[pages > 1] + ", " + username + "."]
		elif random1 == 2:
			if double_sided == True:
				tweets = [	"Double sided too? What am I " + username + ", an HP?", \
							"Going to have to get the duplexer fired up. Thanks a lot, " + username + ".", \
							"Trying to save paper are ya? You know " + username + ", I've got a 525 sheet tray.", \
							"Back in the old days, you had to flip the paper over yourself. You should thank me for doing it for you, " + username + "."]
				
			if double_sided == False:
				tweets = [	"What, my duplexer not good enough for you, " + username + "?", \
							"Makin' me work today, " + username + ". Two sided, eh?", \
							"You keep printing like this and I'm sure to break, " + username + ".", \
							"You have plans for that other side, " + username + "? Because it seems wasted to me."]
	
	random2 = random.randrange(0, len(tweets))
	tweet = tweets[random2] + " #4908cse"
	
	return tweet

def createErrorTweet (error_type, error_val):
	tweets = [	"Hey! I have a " + error_type + " error! Come fix my " + error_val + " error!", \
			"OK who messed up this time? Send someone up to fix my " + error_type + " error: " + error_val + ".", \
			"Another day another problem. I'm having trouble " + error_type + " because " + error_val + ".", \
			"I sure wish you people would stop letting me break. I'm getting sick of this " + error_type + " error called " + error_val + ".",\
			"You know, some proper maintenance wouldn't hurt. Now I have a " + error_type + "error because " + error_val + ".", \
			"What does " + error_val + " mean? Could someone take care of this " + error_type + " error for me?"]
	tweet = tweets[random.randrage(0, len(tweets))] + " #4908cse"
	return tweet


