#= require 'application_socket'

class window.Connection
   constructor: ->
      @socket = new ApplicationSocket('/websocket')

      @socket.addListener(this)

   login: (name, password) ->
      @username = name
      this.command "login"
         username: name
         password: md5(password)

   register: (name, password) ->
      @username = name
      this.command "register"
         username: name
         password: md5(password)

   pm: (name, msg) ->
      this.command "pm"
         username: name
         message: msg

   talk: (msg) ->
      this.command "talk"
         message: msg

   list: ->
      this.command "list"

   go: (dir) ->
      this.command "go"
         direction: dir
# private
   socketOpened: (socket, event) ->
      game_screen.connected()

   socketMessage: (socket, message) ->
      #@message_received(message.type, message.message)

   socketClosed: (socket, event) ->
      game_screen.disconnect()
      # @socket.on "talk", (message) ->
      #    game_screen.user_broadcast message.sender, message.message

      # @socket.on "pm", (message) ->
      #    game_screen.private_message_received message.sender, message.message

      # @socket.on "list", (data) ->
      #    game_screen.user_list(data.users)

      # @socket.on "area", (areaData) ->
      #    game_screen.area(areaData)

      # @socket.on "error", (error) =>
      #    this.error_received(error.type, error.message)

   message: (message) ->
      # @socket.emit "message", message

   command: (command, params) ->
      # @socket.emit "command", command, params

   message_received: (type, message) ->
      switch type
         when "LoginRequired"
            @username = null
            game_screen.message(message)
            login_dialog.show()

         when "LoginSuccess"
            game_screen.message(message)
            login_dialog.hide()

         when "RegistrationSuccess"
            game_screen.message(message)
            registration_dialog.hide()

         else
            game_screen.message(message)

   error_received: (type, message) ->
      switch type
         when "LoginFailure" then alert(message)
         when "RegistrationFailure" then alert(message)
         else
            game_screen.error message