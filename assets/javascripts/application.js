//= require 'chat_controller'

$(document).ready(function(){
  if (typeof(WebSocket) !== 'undefined') {
    $('#ask').show();
    window.chat = new ChatController();
  } else {
    $('#error').show();
  }
});