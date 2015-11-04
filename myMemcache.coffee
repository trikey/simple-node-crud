Memcached = require('memcached')
memcached = new Memcached('localhost:11211')
q = require 'q'

memcached.fetch = (key, fn) ->
	q.Promise (resolve, reject) ->
		memcached.get key, (err, data) ->
			if data?
				console.log 'from cache'
				return resolve data
			else
				q(fn()).then (value) ->
					memcached.set key, value, 3600, (err) ->
						console.log err if err?
						console.log "new #{key}"
						return resolve value

module.exports = memcached