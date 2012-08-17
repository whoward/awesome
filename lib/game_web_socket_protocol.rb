
# this module contains all the helper methods for interacting with the client via
# websocket.  the class including this should define the method "render" to send
# data across the connection.
module GameWebSocketProtocol
   # no public methods

private
   def login_required!
      emit :login_required, message: "Welcome to Seven Helms, please log in or register a new account."
   end

   def login_failure!(message)
      emit :login_failure, message: message
   end

   def login_success!(message)
      emit :login_success, message: message
   end

   def register_failure!(message)
      emit :register_failure, message: message
   end

   def register_success!(message)
      emit :register_success, message: message
   end

   def broadcast!(message)
      emit :broadcast, message: message
   end

   def display_talk!(sender, message)
      emit :talk, sender: sender, message: message
   end

   def display_private_message!(sender, message)
      emit :pm, sender: sender, message: message
   end

   def display_area!(area)
      emit :display_area, area: area.serialized_attributes
   end

   def user_list!(names)
      emit :list, users: names
   end

   def player_leaves_area!(username, direction=nil)
      emit :player_leaves_area, username: username, direction: direction
   end

   def player_enters_area!(username, direction=nil)
      emit :player_enters_area, username: username, direction: direction
   end

   def error_message!(message)
      emit :error, message: message
   end

   def undefined_direction!(message)
      emit :undefined_direction, message: message
   end

   def emit(action, data={})
      render Yajl::Encoder.encode(data.merge(action: action))
   end
   
   def encode_json(obj)
      Yajl::Encoder.encode(obj)
   end
   
   def parse_json(str)
      Yajl::Parser.parse(str, symbolize_keys: true) rescue {}
   end
end