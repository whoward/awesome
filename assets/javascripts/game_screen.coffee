#= require 'lib/jquery.jscrollpane.min'
#= require 'lib/jquery.mousewheel'

#= require 'screen_message_queue'
#= require 'screen_input'


class window.GameScreen
   constructor: (root) ->
      # build up the console divs
      @container = jQuery("<div/>").attr("id", "container").appendTo(root)

      @messages = new ScreenMessageQueue(@container)

      @input = new ScreenInput(@container)

      # each time the viewport resizes update the height of the console container to match
      jQuery(window).resize =>
         @container.css "height", jQuery(window).height() - 20
         @container.css "width", jQuery(window).width() - 40

      jQuery(window).trigger("resize")

      # use a scroll pane (regulated by jQuery) to display the console
      @container.jScrollPane
         maintainPosition: true
         stickToBottom: true
         animateScroll: true
         enableKeyboardNavigation: false
         autoReinitialise: true
         autoReinitialiseDelay: 500

      # and display the console input
      @input.clear()

      # and display a friendly message about help
      @messages.colored "golden-yellow", "type /help for commands"

   submit_input: ->
      input_parser.process_input(@input.get())      
      @input.clear()

   connected: ->
      @messages.colored "red", "Connected to the server."

   disconnect: ->
      @messages.colored "red", "Disconnected from the server."

   message: (message) ->
      @messages.append(message)

   error: (message) ->
      @messages.colored "purple", message

   help: ->
      @messages.colored "golden-yellow", "commands: /say /help /list /go"

   user_list: (users) ->
      @messages.colored "blue", "Users: #{data.users.join(", ")}"

   user_broadcast: (sender, message) ->
      if sender == connection.username
         message = @messages.colored "blue talk", "#{sender}: #{message}".safe()
      else
         message = @messages.classed "talk", "<a href='#'>#{sender}</a>: #{message}".safe()
      
      message.find("a").click =>
         @input.set "/say #{sender}"
         false

   private_message_sent: (recipient, message) ->
      @messages.colored "blue", "to #{recipient}: #{message}"

   private_message_received: (sender, message) ->
      message = @messages.classed "pm", "From (<a href='#'>#{sender}</a>): #{message}".safe()

      message.find("a").click =>
         @input.set "/say #{sender} "
         false

   area: (area) ->
      exit_count = (dir for dir, name of area.exits).length

      @messages.append area.name.h(), "area-header"
      
      @messages.append area.description.h()

      if area.people.length > 1
         @messages.colored "cyan", "There are #{area.people.length} people here: #{area.people.join(", ")}"
      else
         @messages.colored "cyan", "Nobody is here except you."

      @messages.colored "purple", "There are #{exit_count} obvious exits:"

      for dir, name of area.exits
         @messages.colored "purple", "\t#{dir}: #{name}"
