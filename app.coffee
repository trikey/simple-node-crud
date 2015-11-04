express = require 'express'
bodyParser = require('body-parser');

app = express()

app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()

app.set 'views', __dirname + '/views'
#app.set 'view engine', 'jade'
app.set 'view engine', 'ejs'

app.use(express.static(__dirname + '/public'))

Memcached = require('memcached')

memcached = new Memcached('localhost:11211')
memcached.set('foo', 'bar', 10, (err) ->
    console.log(err)
)
memcached.get('foo', (err, data) ->
    console.log(data)
)

Post = require("./models/post")
app.locals.menu = require('./menu')

console.log(app.locals.menu)
app.get('/', (req, res) ->
    Post.forge()
    .fetchAll()
    .then((collection) ->
        items = collection.toJSON()

        if collection?
            res.render 'index',
                items: items
                total: items.length
                title: 'Items'
                activeMenuItem: '/'
        else
            res.json(error: true, data: 'object not found')
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    )
)

app.get('/:id', (req, res) ->
    Post.forge(id: req.params.id)
    .fetch()
    .then((collection) ->
        item = collection.toJSON()
        if collection?
            res.render 'detail',
                item: item
                activeMenuItem: '/'
                title: item.title
        else
            res.json(error: true, data: 'object not found')
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    )
)

app.post('/', (req, res) ->
    Post.forge(
        title: req.body.title
        html: req.body.post
    )
    .save()
    .then((post) ->
        res.json(error: false, data: post.toJSON(), message: "post saved")
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    )
)


app.put('/:id', (req, res) ->
    Post.forge(
        id: req.params.id
        title: req.body.title
        html: req.body.post
    )
    .save()
    .then((post) ->
        res.json(error: false, data: post.toJSON(), message: "post update")
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    )
)


app.delete('/:id', (req, res) ->
    Post.forge(id: req.params.id)
    .destroy()
    .then( ->
        res.json(error: false, message: "post deleted")
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    )
)

app.listen 3000