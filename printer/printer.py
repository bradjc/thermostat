#!/usr/bin/python

from BeautifulSoup import BeautifulSoup
import urllib
import twitter
from time import sleep
from struct import *
import random
import socket
import json
import time

ENABLE_TWEETING = True
ENABLE_GATD     = True

api = twitter.Api(consumer_key='OAicZZPAyI6QsIIr8xFXVw', \
                  consumer_secret='1U6T4P7XC6kjvJxRJzqMtOOVte9A5Quav2XD8cFw',
                  access_token_key='429457401-bk9EdTb6sbX6PCI8trN455QenEL2ycjVg0wIp0Lv', \
                  access_token_secret='n5y56iRBfSNi4xEuiXHTd6EES2fh0eHesZIgEpyUp3w')

GATD_HOST = 'inductor.eecs.umich.edu'
GATD_PORT = 4001
GATD_PID  = '69ARXC5ktb'

PRINTER_URL = 'http://4908priv.eecs.umich.edu'

newestID = 0
firstRun = True
statuses = {}

class printJob:
	def __init__ (self):
		pass

	def __str__ (self):
		out = ''
		out += ' fileName: ' + self.fileName + '\n'
		out += ' pages: ' + str(self.pages) + '\n'
		out += ' sides: ' + str(self.sides) + '\n'
		out += ' duplex: ' + str(self.isDuplex) + '\n'
		out += ' isColor: ' + str(self.isColor) + '\n'
		out += ' user:' + self.userName
		return out


def sendPrinterJobToGatd (pj):
	job_info = {}

#	sendString = ""
	if pj.update_type == 'Job':
		job_info['type']   = 'Print Job'
		job_info['user']   = pj.userName
		job_info['file']   = pj.fileName
		job_info['pages']  = pj.pages
		job_info['sides']  = pj.sides
		job_info['duplex'] = pj.isDuplex
		job_info['color']  = pj.isColor
		job_info['start']  = pj.startTime
		job_info['end']    = pj.endTime

#		sendString = pack('B20s20sii??', 1, str(pj.userName), str(pj.fileName), pj.pages, pj.sides, pj.isDuplex, pj.isColor)

	elif pj.update_type == 'Status':
		job_info['type'] = 'Printer Status'
		job_info['status_type'] = pj.status_type
		job_info['status_val']  = pj.status_val
#		sendString = pack('B20s20s', 2, pj.status_type, pj.status_val)

#	print sendString
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM )
	#sock.sendto("heeyyyy", ("141.212.107.218", 4001))
#	sock.sendto(sendString, ("141.212.107.218", 4001))
	sock.sendto(GATD_PID + json.dumps(job_info), (GATD_HOST, GATD_PORT))
#	print 'done'

# Converts the time string from the printer page to time since epoch in milliseconds
def convertTime (time_str):
	time_str = str(time_str).strip()
	try:
		int(time_str[1])
	except ValueError:
		time_str = '0' + time_str
	t  = time.strptime(time_str, '%m/%d/%Y %H:%M:%S')
	ts = time.mktime(t) - (7*3600)
	return int(ts * 1000)

def parseJobs(soup):
	global newestID

	parsed    = []
	dataTable = soup.find("table", { "id" : "data" })
	rows      = dataTable.findAll('tr')

	for row in rows[2:]:
		cols = row.findAll('td')

#	mostRecent = rows[-1]
#	cols       = mostRecent.findAll('td')

		pj    = printJob()
		pj.id = cols[0].find(text=True)

		if pj.id <= newestID:
			continue

		newestID = pj.id
		print 'New print job found!'
		pj.update_type = 'Job'
		pj.userName    = cols[2].find(text=True)
		if pj.userName == 'Copy':
			# not a person printing
			continue
		pj.fileName  = cols[4].find(text=True)
		pj.pages     = int(cols[6].find(text=True))
		pj.sides     = int(cols[7].find(text=True))
		pj.startTime = convertTime(cols[8].find(text=True))
		pj.endTime   = convertTime(cols[9].find(text=True))
		pj.isDuplex  = pj.pages < pj.sides
		pj.isColor   = float(str.replace(str(cols[13].find(text=True)), '%', '')) != 0.0

		parsed.append(pj)

	return parsed
	#	sendPrinterJob(pj)


def parseErrors(soup):
	global statuses

	errors = []
	statusTables = soup.findAll('table', {'id' : 'statbox'})
	for table in statusTables:
		status_type = str(table.find('b').find('font', text=True).strip())
		status_val  = str(table.find('td').find('font', text=True).strip())

		if not (status_type in statuses):
			statuses[status_type] = ""

		if status_val == "Ready" or \
		   status_val == "Standby" or \
		   status_val == "Printing" or \
		   status_val == "Copying" or \
		   status_val == "Scanning":
			# This isn't an error
			continue

		if status_val != statuses[status_type]:
			# some sort of error and we haven't yet seen it
			print "error: " + status_val + ", " + status_type
			pj = printJob()
			pj.update_type = "Status"
			pj.status_val  = status_val
			pj.status_type = status_type

			print 'Printer status update found'
	#		sendPrinterJob(pj)
			errors.append(pj)
			#api.PostUpdate(createErrorTweet(error_type=status_type, error_val=status_val))

		statuses[status_type] = status_val

	return errors



def createTweet (username, pages, color, double_sided):
	if len(username) > 20:
		username = username[0:16] + "..."

	if username == "_":
		tweets = ["Ugh more printing? I'm probably going to crash soon.", \
		          "Well, well, well now. Aren't we just a privacy printing hippie.", \
		          "I don't approve of this printing nonsense. Couldn't it wait until tomorrow?", \
		          "No username huh? Probably just Pat again.", \
		          "Hey hacker, go find your own printer. Leave me alone!", \
		          "Don't want me to know who you are? We could have been friends. Oh well.", \
		          "Well there goes " + str(pages) + " perfectly good sheet" + ("", "s")[pages>1] + " of paper."]

	elif username == "Copy":
		tweets = ["Copy? Copy?!? You want me to make copies too? I'm only one printer...", \
		          "All this technology and you just want me to make a lousy copy?", \
		          "Do you know how lucky you have it? Back in my day we had to train 7 monks to do this much copying." ]
		if color:
			tweets.extend(["Do you know how much work it is to make a color copy? Gotta fire up the scanner, warm up the black ink, all the colors..."] )

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
			"You know, some proper maintenance wouldn't hurt. Now I have a " + error_type + " error because " + error_val + ".", \
			"What does " + error_val + " mean? Could someone take care of this " + error_type + " error for me?"]
	tweet = tweets[random.randrange(0, len(tweets))] + " #4908cse"
	return tweet




# Get the last print job at the start of running the script
soup      = BeautifulSoup(urllib.urlopen(PRINTER_URL + '/UE/jobaccountingbrowse.html'))
dataTable = soup.find("table", { "id" : "data" })
row       = dataTable.findAll('tr')[-1]
newestID  = row.findAll('td')[0].find(text=True)

print 'Starting id: ' + str(newestID)

# Keep checking for any new print jobs
while True:
	try:
		# Check to see if there are any new print jobs
		soup = BeautifulSoup(urllib.urlopen(PRINTER_URL + '/UE/jobaccountingbrowse.html'))
		pjs  = parseJobs(soup)
		for pj in pjs:
			if ENABLE_TWEETING:
				outputString = createTweet(pj.userName.strip(), pj.pages, pj.isColor, pj.isDuplex)
				print outputString
				api.PostUpdate(outputString)

			if ENABLE_GATD:
				sendPrinterJobToGatd(pj)

		# Check for any errors
		soup = BeautifulSoup(urllib.urlopen(PRINTER_URL + '/status.html'))
		pjs  = parseErrors(soup)
		for pj in pjs:
			if ENABLE_TWEETING:
				outputString = createErrorTweet(error_type=pj.status_type, error_val=pj.status_val)
				api.PostUpdate(outputString)

			if ENABLE_GATD:
				sendPrinterJobToGatd(pj)

	except Exception as e:
		print e
		print 'failed'

	sleep(10)



