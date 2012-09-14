require 'yajl'

# this module contains the basic methods for communicating between the server
# and the client via sockets (particularily WebSockets).  the class including
# this module, or any module derived from it, should implement the render(string)
# method.
module SocketProtocol

private
   def protocol_error!(message)
      emit :error, message: message
   end

   def reconnect!(path)
      emit :reconnect, path: path
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