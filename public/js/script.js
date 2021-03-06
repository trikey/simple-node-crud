// Generated by CoffeeScript 1.10.0
(function() {
  var ready, socket;

  $("#menu-toggle").click(function(e) {
    e.preventDefault();
    return $("#wrapper").toggleClass("toggled");
  });

  socket = io();

  ready = false;

  $('#chat').hide();

  $('#name').focus();

  $("form").not(".custom_form").submit(function(event) {
    return event.preventDefault();
  });

  $("#join").click(function() {
    var name;
    name = $('#name').val();
    if (name !== "") {
      socket.emit("join", name);
      $("#login").detach();
      $("#chat").show();
      $("#msg").focus();
      return ready = true;
    }
  });

  $("#name").keypress(function(e) {
    var name;
    if (e.which === 13) {
      name = $("#name").val();
      if (name !== "") {
        socket.emit("join", name);
        ready = true;
        $("#login").detach();
        $("#chat").show();
        return $("#msg").focus();
      }
    }
  });

  socket.on("update", function(msg) {
    if (ready) {
      return $("#msgs").append("<li>" + msg + "</li>");
    }
  });

  socket.on("update-people", function(people) {
    if (ready) {
      $("#people").empty();
      return $.each(people, function(clientid, name) {
        $('#people').append("<li><strong>" + name + "</strong></li>");
        return $(".people").show();
      });
    }
  });

  socket.on("chat", function(who, msg) {
    if (ready) {
      return $("#msgs").append("<li><strong>" + who + "</strong> пишет: " + msg + "</li>");
    }
  });

  socket.on("disconnect", function() {
    $("#msgs").append("<li><strong style='color: red;'>Не могу подключиться к серверу...</strong> Он меня посылает на хуй :)</li>");
    $("#msg").attr("disabled", "disabled");
    return $("#send").attr("disabled", "disabled");
  });

  $("#send").click(function() {
    var msg;
    msg = $("#msg").val();
    socket.emit("send", msg);
    return $("#msg").val("").focus();
  });

  $("#msg").keypress(function(e) {
    var msg;
    if (e.which === 13) {
      msg = $("#msg").val();
      socket.emit("send", msg);
      return $("#msg").val("");
    }
  });

  $('.posts-table').editableTableWidget();

  $('.posts-table td').on('change', function(evt, newValue) {
    var id, updateData, url;
    id = $(evt.target).parent().attr('data-id');
    url = $(evt.target).parent().attr('data-url');
    updateData = {};
    updateData['id'] = id;
    return $(evt.target).parent().find('td').not('.non-editable').each(function() {
      return updateData[$(this).attr('data-column-name')] = $(this).text();
    }).promise().done(function() {
      return $.ajax({
        type: 'put',
        url: url + id,
        data: updateData
      }).done(function(data) {
        return console.log(data);
      });
    });
  });

  $('.posts-table td.delete').on('click', function() {
    var id, url;
    id = $(this).parent().attr('data-id');
    url = $(this).parent().attr('data-url');
    return $.ajax({
      type: 'delete',
      url: url + id
    }).done(function(data) {
      console.log(data);
      return window.location.reload();
    });
  });

  $('.add-item').on('click', function() {
    var table;
    table = $(this).attr('data-table');
    return $.ajax({
      type: 'get',
      url: '/add',
      data: {
        table: table
      }
    }).done(function(data) {
      $('body').append(data);
      $('.custom-modal .hide').show();
      $('.custom-modal').modal();
      return $('.custom-modal').on('hidden', function() {
        console.log("hidden");
        return $('.custom-modal').remove();
      });
    });
  });

  $(document).on('click', '#add_item', function() {
    var error_found;
    error_found = false;
    $(this).parents('form').find('input[type=text]').each(function() {
      if ($(this).attr('required') === 'required' && !$(this).val().length) {
        $(this).parent().addClass('has-error');
        return error_found = true;
      } else {
        return $(this).parent().removeClass('has-error');
      }
    }).promise().done(function() {
      if (!error_found) {
        return $.ajax({
          type: 'post',
          url: $(this).parents('form').attr('action'),
          data: $(this).parents('form').serialize(),
          dataType: 'json'
        }).done(function(data) {
          if (data.error) {
            return $('#error').text(data.message);
          } else {
            return window.location.reload();
          }
        });
      }
    });
    return false;
  });

}).call(this);

//# sourceMappingURL=script.js.map
