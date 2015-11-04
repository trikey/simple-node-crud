mem = require './myMemcache'
q = require 'q'
Post = require './models/post'
mem.del 'items_list', ->

#	fn = ->
#		Post.forge().fetchAll()
#		.then (collection) -> collection.toJSON()
#		.catch (err) ->
#			res.status(500).json(error: true, data: message: err.message)
#	mem.fetch 'items_list', fn
#	.then (data) ->
#		console.log data