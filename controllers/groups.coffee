module.exports = (app) ->

    Group = require("../models/group")
    app.post('/groups', (req, res) ->
        date = new Date()
        mysqlDateTime = date.toMysqlFormat()
        Group.forge(
            title: req.body.title
            created_at : mysqlDateTime
        )
        .save()
        .then((user) ->
            res.json(error: false, data: user.toJSON(), message: "group saved")
        )
        .catch( (err) ->
            res.status(500).json(error: true, data: message: err.message)
        )
    )


    app.put('/groups/:id', (req, res) ->
        date = new Date()
        mysqlDateTime = date.toMysqlFormat()
        Group.forge(
            id: req.params.id
            title: req.body.title
            updated_at : mysqlDateTime
        )
        .save()
        .then((user) ->
            res.json(error: false, data: user.toJSON(), message: "group update")
        )
        .catch( (err) ->
            res.status(500).json(error: true, data: message: err.message)
        )
    )


    app.delete('/groups/:id', (req, res) ->
        Group.forge(id: req.params.id)
        .destroy()
        .then( ->
            res.json(error: false, message: "group deleted")
        )
        .catch( (err) ->
            res.status(500).json(error: true, data: message: err.message)
        )
    )