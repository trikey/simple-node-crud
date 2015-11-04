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

Post = require("./models/post")
app.locals.menu = require('./menu')

app.get('/', (req, res) ->

    memcached.get('items_list', (err, data) ->
        console.log 'get items from cache'
        if data?
            items = data
            if items?
                res.render 'index',
                    items: items
                    total: items.length
                    title: 'Items'
                    activeMenuItem: '/'
            else
                res.json(error: true, data: 'object not found')
        else
            Post.forge()
            .fetchAll()
            .then((collection) ->
                items = collection.toJSON()
                console.log 'new cache'
                memcached.set('items_list', items, 3600, (err) ->
                    console.log err if err?
                )
                if items?
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


)

app.get('/:id', (req, res) ->
    memcached.get("item#{req.params.id}", (err, data) ->
        console.log "get item#{req.params.id} from cache"
        if data?
            item = data
            if item?
                res.render 'detail',
                    item: item
                    activeMenuItem: '/'
                    title: item.title
            else
                res.json(error: true, data: 'object not found')
        else
            Post.forge(id: req.params.id)
            .fetch()
            .then((collection) ->
                item = collection.toJSON()
                console.log "new cache item#{req.params.id}"
                memcached.set("item#{req.params.id}", item, 3600, (err) ->
                    console.log err if err?
                )
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