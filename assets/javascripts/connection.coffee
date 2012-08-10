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

         when "error"
            GameScreen.instance.error(message.message)

         else
            console?.log("unhandled action: ", action, message)


   socketClosed: (socket, event) ->
      GameScreen.instance.disconnect()

      # @socket.on "pm", (message) ->
      #    game_screen.private_message_received message.sender, message.message

      # @socket.on "list", (data) ->
      #    game_screen.user_list(data.users)

      # @socket.on "error", (error) =>
      #    this.error_received(error.type, error.message)

   message: (message) ->
      # @socket.emit "message", message

   command: (command, params) ->
      params.action = command
      @socket.send(params)
