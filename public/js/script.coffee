$("#menu-toggle").click (e) ->
    e.preventDefault();
    $("#wrapper").toggleClass("toggled")


socket = io();
ready = false

$('#chat').hide()
$('#name').focus()

$("form").submit (event) ->
    event.preventDefault()


$("#join").click ->
    name = $('#name').val()
    if (name != "")
        socket.emit("join", name)
        $("#login").detach()
        $("#chat").show()
        $("#msg").focus()
        ready = true


$("#name").keypress (e) ->
    if(e.which == 13)
        name = $("#name").val()
        if (name != "")
            socket.emit("join", name)
            ready = true
            $("#login").detach()
            $("#chat").show()
            $("#msg").focus()


socket.on "update", (msg) ->
    $("#msgs").append("<li>#{msg}</li>") if (ready)


socket.on "update-people", (people) ->
    if(ready)
        $("#people").empty()
        $.each(people, (clientid, name) ->
            $('#people').append("<li>#{name}</li>")
        )

socket.on "chat", (who, msg) ->
    $("#msgs").append("<li><strong>#{who}</strong> пишет: #{msg}</li>") if (ready)

socket.on "disconnect", ->
    $("#msgs").append("<li><strong style='color: red;'>Не могу подключиться к серверу...</strong> Он меня посылает на хуй :)</li>")
    $("#msg").attr("disabled", "disabled")
    $("#send").attr("disabled", "disabled")


$("#send").click ->
    msg = $("#msg").val()
    socket.emit("send", msg)
    $("#msg").val("").focus()

$("#msg").keypress (e) ->
    if(e.which == 13)
        msg = $("#msg").val()
        socket.emit("send", msg)
        $("#msg").val("")



#$('form').submit ->
#    socket.emit('chat message', $('#m').val())
#    $('#m').val('')
#    false
#
#socket.on 'chat message', (msg) ->
#    $('#messages').append($('<li>').text(msg))