express = require 'express'
bodyParser = require('body-parser')
cookieParser = require('cookie-parser')
session = require('express-session')
passport = require('passport')
bcrypt = require('bcrypt-nodejs')
async = require('async')
fs = require('fs')
requireRoutes = require('express-require-routes');


app = express()
http = require('http').Server(app);
io = require('socket.io')(http)

app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()

app.set 'views', __dirname + '/views'
app.set 'view engine', 'ejs'

app.use(express.static(__dirname + '/public'))

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
#app.use(app.router)

app.locals.menu = require('./menu')


twoDigits = (d) ->
    return "0" + d.toString() if(0 <= d && d < 10)
    return "-0" + (-1*d).toString() if(-10 < d && d < 0)
    return d.toString()

Date.prototype.toMysqlFormat = ->
    this.getUTCFullYear() + "-" + twoDigits(1 + this.getUTCMonth()) + "-" + twoDigits(this.getUTCDate()) + " " + twoDigits(this.getUTCHours()) + ":" + twoDigits(this.getUTCMinutes()) + ":" + twoDigits(this.getUTCSeconds())


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



requireRoutes('controllers', app)