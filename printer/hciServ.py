#!/usr/bin/python

from twisted.web import server, resource
from twisted.internet import reactor

class MainResource(resource.Resource):
	def render_GET(self, request):
		return "."

class ClientEndpoint(resource.Resource):
	isLeaf = True
	def render_GET(self, request):
		return "Hello world, I'm happy, and located at %s" % request.postpath
	def render_POST(self, request):
		return "That was a post request!"

class ServiceEndpoint(resource.Resource):
	isLeaf = True
	def render_POST(self, request):
		return "That was a post request...."

rootResource = MainResource()
rootResource.putChild('serviceEndpoint', ServiceEndpoint())
rootResource.putChild('clientEndpoint', ClientEndpoint())

site = server.Site(rootResource)
reactor.listenTCP(8080, site)
reactor.run()

class PhraseGenerator:
	pass
