module.exports = (app) ->

    app.get('/chat/', (req, res) ->
        res.render 'chat',
            title: 'Чат',
            activeMenuItem: '/chat/'
    )