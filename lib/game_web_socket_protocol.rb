
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

   def display_area!(area)
      emit :display_area, area: area.serialized_attributes
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