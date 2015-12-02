module.exports = (app) ->

    User = require("../models/user")
    app.post('/users', (req, res) ->
        date = new Date()
        mysqlDateTime = date.toMysqlFormat()
        User.forge(
            username: req.body.username
            password: bcrypt.hashSync(req.body.password)
            is_admin: 1
            created_at : mysqlDateTime
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
        date = new Date()
        mysqlDateTime = date.toMysqlFormat()
        User.forge(
            id: req.params.id
            username: req.body.username
            is_admin: req.body.is_admin
            updated_at : mysqlDateTime
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