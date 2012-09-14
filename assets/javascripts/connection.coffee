#= require 'application_socket'

class Connection extends BasicObject
   constructor: ->
      @socket = new ApplicationSocket('/games')

      @socket.addListener(this)

   @get "instance", ->
      @__instance ||= new Connection()

   sendSessionToken: (token) ->
      @command "session"
         token: token

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

   setToken: (token) ->
      @token = token

      localStorage?._session_token = token

   getToken: ->
      @token ||= localStorage?._session_token

   socketOpened: (socket, event) ->
      GameScreen.instance.connected()

   socketMessage: (socket, data) ->
      action = data.action

      data.action = undefined

      switch action
         when "error"
            console?.error(data.message)

         when "reconnect"
            @socket.reconnect(data.path)

         when "session"
            @setToken(data.token)
            @username = data.username

         when "talk"
            GameScreen.instance.user_broadcast(data.sender, data.message)

         when "pm"
            GameScreen.instance.private_message_received(data.sender, data.message)

         when "broadcast"
            GameScreen.instance.message(data.message)

         when "display_area"
            GameScreen.instance.area(data.area)

         when "identify"
            @username = null

            token = @getToken()

            console.log("received identify command, token: ", token)

            if token
               console.log("sending token")
               @sendSessionToken(token)
            else
               console.log("showing login screen")
               LoginDialog.instance.show()

         when "session_failure"
            console?.error(data.message)

            @setToken null
            
            LoginDialog.instance.show()

         when "login_success"
            GameScreen.instance.message(data.message)
            LoginDialog.instance.hide()
            RegistrationDialog.instance.hide()

         when "login_failure"
            alert(data.message)

         when "register_failure"
            alert(data.message)

         when "register_success"
            GameScreen.instance.message(data.message)
            LoginDialog.instance.hide()
            RegistrationDialog.instance.hide()

         when "list"
            GameScreen.instance.user_list(data.users)

         when "player_enters_area"
            GameScreen.instance.player_enters_area(data.username, data.direction)

         when "player_leaves_area"
            GameScreen.instance.player_leaves_area(data.username, data.direction)

         when "user_error"
            GameScreen.instance.error(data.message)

         when "undefined_direction"
            GameScreen.instance.error "You can't go that way"

         else
            console?.log("unhandled action: ", action, message)


   socketClosed: (socket, event) ->
      GameScreen.instance.disconnect()

   command: (command, params={}) ->
      params.action = command
      @socket.send(params)
