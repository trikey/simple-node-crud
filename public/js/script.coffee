$("#menu-toggle").click (e) ->
    e.preventDefault();
    $("#wrapper").toggleClass("toggled")


socket = io();
ready = false

$('#chat').hide()
$('#name').focus()

$("form").not(".custom_form").submit (event) ->
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
            $('#people').append("<li><strong>#{name}</strong></li>")
            $(".people").show()
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


$('.posts-table').editableTableWidget()

$('.posts-table td').on('change', (evt, newValue) ->
    id = $(evt.target).parent().attr('data-id')
    url = $(evt.target).parent().attr('data-url')
    updateData = {}
    updateData['id'] = id
    $(evt.target).parent().find('td').not('.non-editable').each ->
        updateData[$(this).attr('data-column-name')] = $(this).text()
    .promise().done ->
        $.ajax
            type: 'put',
            url: url + id,
            data: updateData
        .done (data) ->
            console.log data
)

$('.posts-table td.delete').on('click', ->
    id = $(this).parent().attr('data-id')
    url = $(this).parent().attr('data-url')
    $.ajax
        type: 'delete',
        url: url + id,
    .done (data) ->
        console.log data
        window.location.reload()
)

$('.add-item').on('click', ->
    table = $(this).attr('data-table')
    $.ajax
        type: 'get',
        url: '/add',
        data:
            table: table
    .done (data) ->
        $('body').append(data)
        $('.custom-modal .hide').show()
        $('.custom-modal').modal()
        $('.custom-modal').on('hidden', ->
            console.log("hidden")
            $('.custom-modal').remove()
        )
)

$(document).on('click', '#add_item', ->
    error_found = false
    $(this).parents('form').find('input[type=text]').each ->
        if $(this).attr('required') == 'required' and !$(this).val().length
            $(this).parent().addClass('has-error')
            error_found = true
        else
            $(this).parent().removeClass('has-error')
    .promise().done ->
        if !error_found
            $.ajax
                type: 'post',
                url: $(this).parents('form').attr('action'),
                data: $(this).parents('form').serialize(),
                dataType: 'json'
            .done (data) ->
                if data.error
                    $('#error').text(data.message)
                else
                    window.location.reload()
    return false
)