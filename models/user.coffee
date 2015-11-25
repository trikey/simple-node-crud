Config = require('../config')
knex = require('knex')(Config)
bookshelf = require('bookshelf')(knex);

User = bookshelf.Model.extend
    tableName: 'users'

module.exports = User