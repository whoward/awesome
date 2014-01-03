
# this module handles all data parsing and dispatching of actions received from
# the client.  it is also responsible for handling authentication requests and
# refreshing the session token.
module GameWebSocketHandler

   #TODO: at about 80% of it's lifetime, refresh and send the user a new session token

   def self.included(base)
      base.send(:on_data, :data_received)
   end

   def data_received(data)
      msg = parse_json(data) #TODO: rescue malformed data

      handler_method = "handle_#{msg[:action]}"

      #TODO: use a state machine for session, if not validated then do not allow
      # any action.

      if respond_to?(handler_method, false)
         send(handler_method, msg)
      else
         puts "unhandled message action: #{msg[:action].inspect}"
      end
   end

   def handle_session(data)
      SessionHandler.new(self, data).perform
   end

   def handle_login(data)
      LoginHandler.new(self, data).perform
   end

   def handle_register(data)
      RegisterHandler.new(self, data).perform
   end
end