CommandRegex = /^\/([A-Za-z]+)(\s+(.+))?/

class window.InputParser

   process_input: (message) ->
      if match = CommandRegex.exec(message)
         this.processCommand(match[1], match[3])

      else if message is "/"
         game_screen.error "Sorry, I don't understand what kind of command you're trying to do"
      
      else
         connection.talk(message)

   processCommand: (command, text) ->
      switch command
         when "say"
            [username, message] = (/^([A-Za-z0-9\_\-]+)\s+(.+)/.exec(text) || ["", "", ""])[1..]
            if username and message
               connection.pm username, message
               game_screen.private_message_sent username, message
            else
               game_screen.error "usage: /say <username> <message>".html_escape()

         when "go" then connection.go(text)

         when "list" then connection.list()

         when "help" then game_screen.help()

         else game_screen.error "Sorry, I don't understand the command \"#{command}\""

