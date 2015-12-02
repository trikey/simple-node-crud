module.exports = (app) ->
    async = require('async')
    Post = require("../models/post")
    User = require("../models/user")
    Group = require("../models/group")
    UserInGroup = require("../models/useringroup")

    app.get('/admin', (req, res) ->
        if(!req.isAuthenticated())
            res.redirect('/auth')
        else
            posts = false
            users = false
            groups = false
            usersingroup = false
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
                    (callback) ->
                        Group.forge().fetchAll()
                        .then (collection) ->
                            groups = collection.toJSON()
                            callback()
                    (callback) ->
                        UserInGroup.forge().fetchAll()
                        .then (collection) ->
                            usersingroup = collection.toJSON()
                            callback()
                ],
            (err) ->
                res.render 'admin',
                    activeMenuItem: '/admin/'
                    title: 'index admin'
                    posts: posts
                    users: users
                    groups: groups
                    usersingroup: usersingroup
            )
    )

    app.get('/add', (req, res) ->
        console.log req.query
        if req.query.table?
            if req.query.table == 'adduseringroup'
                users = false
                groups = false
                async.parallel(
                    [
                        (callback) ->
                            User.forge().fetchAll()
                            .then (collection) ->
                                users = collection.toJSON()
                                callback()
                        (callback) ->
                            Group.forge().fetchAll()
                            .then (collection) ->
                                groups = collection.toJSON()
                                callback()
                    ],
                (err) ->
                    res.render req.query.table,
                        users: users
                        groups: groups
                )
            else
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
