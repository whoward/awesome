#= require 'application_socket'

class Connection extends BasicObject
   constructor: ->
      @socket = new ApplicationSocket('/websocket')

      @socket.addListener(this)

   @get "instance", ->
      @__instance ||= new Connection()

   login: (name, password) ->
      @username = name
      @command "login"
         username: name
         password: password

   register: (name, password) ->
      @username = name
      @command "register"
         username: name
         password: password

   pm: (name, msg) ->
      @command "pm"
         username: name
         message: msg

   talk: (msg) ->
      @command "talk"
         message: msg

   list: ->
      @command "list"

   go: (dir) ->
      @command "travel"
         direction: dir
         
# private
   socketOpened: (socket, event) ->
      GameScreen.instance.connected()

   socketMessage: (socket, message) ->
      action = message.action

      message.action = undefined

      switch action
         when "talk"
            GameScreen.instance.user_broadcast(message.sender, message.message)

         when "pm"
            GameScreen.instance.private_message_received(message.sender, message.message)

         when "broadcast"
            GameScreen.instance.message(message.message)

         when "display_area"
            GameScreen.instance.area(message.area)

         when "login_required"
            @username = null
            GameScreen.instance.message(message.message)
            LoginDialog.instance.show()

         when "login_success"
            GameScreen.instance.message(message.message)
            LoginDialog.instance.hide()
            RegistrationDialog.instance.hide()

         when "login_failure"
            alert(message.message)

         when "register_failure"
            alert(message.message)

         when "register_success"
            GameScreen.instance.message(message.message)
            LoginDialog.instance.hide()
            RegistrationDialog.instance.hide()

         when "list"
            GameScreen.instance.user_list(message.users)

         when "player_enters_area"
            GameScreen.instance.player_enters_area(message.username, message.direction)

         when "player_leaves_area"
            GameScreen.instance.player_leaves_area(message.username, message.direction)

         when "error"
            GameScreen.instance.error(message.message)

         when "undefined_direction"
            GameScreen.instance.error "You can't go that way"

         else
            console?.log("unhandled action: ", action, message)


   socketClosed: (socket, event) ->
      GameScreen.instance.disconnect()

   command: (command, params={}) ->
      params.action = command
      @socket.send(params)
