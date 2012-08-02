#= require 'application_socket'

class ChatController

   constructor: ->
      @socket = new ApplicationSocket('/websocket')

      @socket.addListener(this)

      jQuery("#ask a").click (ev) =>
         @join(jQuery("#ask input").val())
         
         jQuery('#ask').hide();
         jQuery('#channel').show();
         jQuery('input#message').focus();

         false

      jQuery('#channel form').submit (ev) =>
         input = jQuery(ev.target).find('input')
         @socket.send(action: 'message', message: input.val())
         input.val('')
         false

   join: (username) ->
      @username = username

      @socket.send(action: 'join', user: username)

   socketMessage: (socket, message) ->
      container = jQuery("#msgs")

      struct = container.find("li.#{message.action}:first")

      return unless struct.length

      msg = struct.clone()
      msg.find('.time').text((new Date()).toString("HH:mm:ss"))

      switch message.action
         when "message"
            matches = message.message.match(/^\s*[\/\\]me\s(.*)/)

            if matches
               msg.find('.user').text(message['user'] + ' ' + matches[1])
               msg.find('.user').css('font-weight', 'bold')
            else
               msg.find('.user').text(message['user'])
               msg.find('.message').text(': ' + message['message'])

         when "control"
           msg.find('.user').text(message['user']);
           msg.find('.message').text(message['message']);
           msg.addClass('control');
      
      if message.user is @username
         msg.find('.user').addClass('self')
      

      container.find('ul').append(msg.show())

      container.scrollTop(container.find('ul').innerHeight())


