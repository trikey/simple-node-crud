module.exports = (app) ->
    UserInGroup = require("../models/useringroup")

    app.post('/usersingroup', (req, res) ->
        date = new Date()
        mysqlDateTime = date.toMysqlFormat()
        UserInGroup.forge(
            user_id: req.body.user_id
            group_id: req.body.group_id
            created_at : mysqlDateTime
        )
        .save()
        .then((user) ->
            res.json(error: false, data: user.toJSON(), message: "user in group saved")
        )
        .catch( (err) ->
            res.status(500).json(error: true, data: message: err.message)
        )
    )


    app.put('/usersingroup/:id', (req, res) ->
        date = new Date()
        mysqlDateTime = date.toMysqlFormat()
        UserInGroup.forge(
            id: req.params.id
            user_id: req.body.user_id
            group_id: req.body.group_id
            updated_at : mysqlDateTime
        )
        .save()
        .then((user) ->
            res.json(error: false, data: user.toJSON(), message: "user in group update")
        )
        .catch( (err) ->
            res.status(500).json(error: true, data: message: err.message)
        )
    )


    app.delete('/usersingroup/:id', (req, res) ->
        UserInGroup.forge(id: req.params.id)
        .destroy()
        .then( ->
            res.json(error: false, message: "user in group deleted")
        )
        .catch( (err) ->
            res.status(500).json(error: true, data: message: err.message)
        )
    )