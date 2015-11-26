express = require 'express'
bodyParser = require('body-parser')
cookieParser = require('cookie-parser')
session = require('express-session')
passport = require('passport')
bcrypt = require('bcrypt-nodejs')
async = require('async')

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
User = require("./models/user")

LocalStrategy = require('passport-local').Strategy
passport.use(new LocalStrategy((username, password, done) ->
    User.forge(
        username: username
    )
    .fetch()
    .then((data) ->
        user = data
        if(user is null)
            return done(null, false, {message: 'Неверное имя пользователя или пароль'})
        else
            user = data.toJSON();
            if(!bcrypt.compareSync(password, user.password))
                return done(null, false, {message: 'Неверное имя пользователя или пароль'})
            else
                return done(null, user)
    )
))

passport.serializeUser((user, done) ->
    done(null, user.username)
)

passport.deserializeUser((username, done) ->
    User.forge(
        username: username
    )
    .fetch()
    .then((user) ->
        done(null, user)
    )
)

app.use(cookieParser())
app.use(session({secret: 'swordfish1992'}))
app.use(passport.initialize())
app.use(passport.session())


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

posts = false
users = false
app.get('/admin', (req, res) ->
    if(!req.isAuthenticated())
        res.redirect('/auth')
    else

        async.parallel(
            [
                (callback) ->
                    Post.forge().fetchAll()
                        .then (collection) ->
                            posts = collection.toJSON()
                            callback()
                (callback) ->
                    User.forge().fetchAll()
                        .then (collection) ->
                            users = collection.toJSON()
                            callback()
            ],
            (err) ->
                res.render 'admin',
                    activeMenuItem: '/admin/'
                    title: 'index admin'
                    posts: posts
                    users: users
        )
)

app.get('/add', (req, res) ->
    console.log req.query
    if req.query.table?
        res.render req.query.table
    else
        res.status(500).json(error: true, data: message: "не найден вид")
)

app.get('/auth', (req, res) ->
    if(req.isAuthenticated())
        res.redirect('/')
    else
        res.render 'auth',
            activeMenuItem: '/auth/'
            title: 'Авторизация'
)

app.post('/auth', (req, res) ->
    passport.authenticate('local',
        successRedirect: '/admin'
        failureRedirect: '/auth'
    (err, user, info) ->
        return res.render('auth',
            activeMenuItem: '/auth/'
            title: 'Авторизация'
            message: err.message
        ) if err
        return res.render('auth',
            activeMenuItem: '/auth/'
            title: 'Авторизация'
            message: info.message
        ) if !user

        return req.logIn(user, (err) ->
            if(err)
                return res.render('auth',
                    activeMenuItem: '/auth/',
                    title: 'Авторизация',
                    message: err.message
                )
            else
                return res.redirect('/admin')
        )
    )(req, res)
)

app.post('/users', (req, res) ->
    User.forge(
        username: req.body.username
        password: bcrypt.hashSync(req.body.password)
        is_admin: 1
    )
    .save()
    .then((user) ->
        res.json(error: false, data: user.toJSON(), message: "user saved")
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    )
)


app.put('/users/:id', (req, res) ->
    User.forge(
        id: req.params.id
        username: req.body.username
        is_admin: req.body.is_admin
    )
    .save()
    .then((user) ->
        res.json(error: false, data: user.toJSON(), message: "user update")
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    )
)


app.delete('/users/:id', (req, res) ->
    User.forge(id: req.params.id)
    .destroy()
    .then( ->
        res.json(error: false, message: "user deleted")
    )
    .catch( (err) ->
        res.status(500).json(error: true, data: message: err.message)
    )
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


