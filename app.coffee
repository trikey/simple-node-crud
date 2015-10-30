express = require 'express'
stylus = require 'stylus'
nib = require 'nib'
Config = require('./config')
knex = require('knex')(Config)
bookshelf = require('bookshelf')(knex);

app = express()

bodyParser = require('body-parser');
app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()

compile = (str, path) ->
    stylus(str)
        .set('filename', path)
        .use(nib())

app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'

app.use(stylus.middleware
    src: __dirname + '/public'
    compile: compile
)

app.use(express.static(__dirname + '/public'))


Post = require("./models/post")

app.get('/', (req, res) ->
    Post.forge()
    .fetch()
    .then((collection) ->
        res.json(error: false, data: collection.toJSON()) if collection?
        res.json(error: true, data: 'object not found')
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    );
)

app.get('/:id', (req, res) ->
    Post.forge(id: req.params.id)
    .fetch()
    .then((collection) ->
        res.json(error: false, data: collection.toJSON()) if collection?
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