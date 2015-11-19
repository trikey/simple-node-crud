express = require 'express'
bodyParser = require('body-parser');

app = express()
http = require('http').Server(app);
io = require('socket.io')(http)

app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()

app.set 'views', __dirname + '/views'
app.set 'view engine', 'ejs'

app.use(express.static(__dirname + '/public'))

memcached = require('./myMemcache')

Post = require("./models/post")
app.locals.menu = require('./menu')

http.listen 3000, ->
    console.log('listening on *:3000')

people = {}
io.on 'connection', (socket) ->
    console.log('a user connected')
    socket.on 'disconnect', ->
        console.log('user disconnected')
        io.emit("update", people[socket.id] + " ушел нахуй с сервера")
        delete people[socket.id]
        io.emit("update-people", people)

    socket.on 'chat message', (msg) ->
        console.log('message: ' + msg)
        io.emit('chat message', msg)

    socket.on 'join', (name) ->
        console.log name
        people[socket.id] = name
        socket.emit('update', 'Вы присоединились к серверу')
        io.emit('update', name + ' присоединился к серверу')
        io.emit('update-people', people)

    socket.on 'send', (msg) ->
        console.log(msg)
        console.log(people[socket.id])
        io.emit('chat', people[socket.id], msg)


app.get('/chat/', (req, res) ->
    res.render 'chat',
        title: 'Чат',
        activeMenuItem: '/chat/'
)



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

#app.listen 3000