Config = require('../config')
knex = require('knex')(Config)
bookshelf = require('bookshelf')(knex);

Group = bookshelf.Model.extend
    tableName: 'groups'

module.exports = Group