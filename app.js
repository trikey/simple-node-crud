// Generated by CoffeeScript 1.10.0
(function() {
  var Post, app, bodyParser, express, memcached;

  express = require('express');

  bodyParser = require('body-parser');

  app = express();

  app.use(bodyParser.urlencoded({
    extended: true
  }));

  app.use(bodyParser.json());

  app.set('views', __dirname + '/views');

  app.set('view engine', 'ejs');

  app.use(express["static"](__dirname + '/public'));

  memcached = require('./myMemcache');

  Post = require("./models/post");

  app.locals.menu = require('./menu');

  app.get('/', function(req, res) {
    var getItems;
    getItems = function() {
      return Post.forge().fetchAll().then(function(collection) {
        return collection.toJSON();
      })["catch"](function(err) {
        return res.status(500).json({
          error: true,
          data: {
            message: err.message
          }
        });
      });
    };
    return memcached.fetch('items_list', getItems).then(function(items) {
      if (items != null) {
        return res.render('index', {
          items: items,
          total: items.length,
          title: 'Items',
          activeMenuItem: '/'
        });
      } else {
        return res.json({
          error: true,
          data: 'object not found'
        });
      }
    });
  });

  app.get('/:id', function(req, res) {
    var getItem;
    getItem = function() {
      return Post.forge({
        id: req.params.id
      }).fetch().then(function(collection) {
        return collection.toJSON();
      })["catch"](function(err) {
        return res.status(500).json({
          error: true,
          data: {
            message: err.message
          }
        });
      });
    };
    return memcached.fetch("item" + req.params.id, getItem).then(function(data) {
      var item;
      item = data;
      if (item != null) {
        return res.render('detail', {
          item: item,
          activeMenuItem: '/',
          title: item.title
        });
      } else {
        return res.json({
          error: true,
          data: 'object not found'
        });
      }
    });
  });

  app.post('/', function(req, res) {
    return Post.forge({
      title: req.body.title,
      html: req.body.post
    }).save().then(function(post) {
      return res.json({
        error: false,
        data: post.toJSON(),
        message: "post saved"
      });
    })["catch"](function(err) {
      return res.status(500).json({
        error: true,
        data: {
          message: err.message
        }
      });
    });
  });

  app.put('/:id', function(req, res) {
    return Post.forge({
      id: req.params.id,
      title: req.body.title,
      html: req.body.post
    }).save().then(function(post) {
      return res.json({
        error: false,
        data: post.toJSON(),
        message: "post update"
      });
    })["catch"](function(err) {
      return res.status(500).json({
        error: true,
        data: {
          message: err.message
        }
      });
    });
  });

  app["delete"]('/:id', function(req, res) {
    return Post.forge({
      id: req.params.id
    }).destroy().then(function() {
      return res.json({
        error: false,
        message: "post deleted"
      });
    })["catch"](function(err) {
      return res.status(500).json({
        error: true,
        data: {
          message: err.message
        }
      });
    });
  });

  app.listen(3000);

}).call(this);

//# sourceMappingURL=app.js.map
