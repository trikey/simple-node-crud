var io = require('socket.io').listen(3000)
io.sockets.on('connection', function(socket) {
    socket.emit('hello', 'hello from io!');
});