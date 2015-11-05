$("#menu-toggle").click (e) ->
    e.preventDefault();
    $("#wrapper").toggleClass("toggled")


socket = io();

$('form').submit ->
    socket.emit('chat message', $('#m').val())
    $('#m').val('')
    false

socket.on 'chat message', (msg) ->
    $('#messages').append($('<li>').text(msg))