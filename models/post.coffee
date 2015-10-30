Config = require('../config')
knex = require('knex')(Config)
bookshelf = require('bookshelf')(knex);

Post = bookshelf.Model.extend
    tableName: 'posts'

module.exports = Post