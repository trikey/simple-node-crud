module.exports = (app) ->

    Post = require("../models/post")

    memcached = require('../myMemcache')


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
        date = new Date()
        mysqlDateTime = date.toMysqlFormat()
        Post.forge(
            title: req.body.title
            html: req.body.post
            created_at: mysqlDateTime
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
        date = new Date()
        mysqlDateTime = date.toMysqlFormat()
        Post.forge(
            id: req.params.id
            title: req.body.title
            html: req.body.post
            updated_at: mysqlDateTime
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
