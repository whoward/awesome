CommandRegex = /^\/([A-Za-z]+)(\s+(.+))?/

class InputParser extends BasicObject

   @get "instance", ->
      @__instance ||= new InputParser()

   process_input: (message) ->
      if match = CommandRegex.exec(message)
         this.processCommand(match[1], match[3])

      else if message is "/"
         GameScreen.instance.error "Sorry, I don't understand what kind of command you're trying to do"
      
      else
         Connection.instance.talk(message)

   processCommand: (command, text) ->
      switch command
         when "say"
            [username, message] = (/^([A-Za-z0-9\_\-]+)\s+(.+)/.exec(text) || ["", "", ""])[1..]
            if username and message
               Connection.instance.pm username, message
               GameScreen.instance.private_message_sent username, message
            else
               GameScreen.instance.error "usage: /say <username> <message>".html_escape()

         when "go" then Connection.instance.go(text)

         when "list" then Connection.instance.list()

         when "help" then GameScreen.instance.help()

         else GameScreen.instance.error "Sorry, I don't understand the command \"#{command}\""

