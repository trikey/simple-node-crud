Config = require('../config')
knex = require('knex')(Config)
bookshelf = require('bookshelf')(knex);

UserInGroup = bookshelf.Model.extend
    tableName: 'user_in_groups'

module.exports = UserInGroup