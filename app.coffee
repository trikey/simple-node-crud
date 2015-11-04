express = require 'express'
bodyParser = require('body-parser');

app = express()

app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()

app.set 'views', __dirname + '/views'
app.set 'view engine', 'ejs'

app.use(express.static(__dirname + '/public'))

memcached = require('./myMemcache')

Post = require("./models/post")
app.locals.menu = require('./menu')

app.get('/', (req, res) ->

    getItems = ->
        Post.forge().fetchAll()
        .then (collection) -> collection.toJSON()
        .catch (err) ->
            res.status(500).json(error: true, data: message: err.message)


    memcached.fetch 'items_list', getItems
    .then (items) ->
        if items?
            res.render 'index',
                items: items
                total: items.length
                title: 'Items'
                activeMenuItem: '/'
        else
            res.json(error: true, data: 'object not found')

)

app.get('/:id', (req, res) ->

    getItem = ->
        Post.forge(id: req.params.id)
        .fetch()
        .then (collection) -> collection.toJSON()
        .catch (err) ->
            res.status(500).json(error: true, data: message: err.message)

    memcached.fetch "item#{req.params.id}", getItem
    .then (data) ->
        item = data
        if item?
            res.render 'detail',
                item: item
                activeMenuItem: '/'
                title: item.title
        else
            res.json(error: true, data: 'object not found')

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