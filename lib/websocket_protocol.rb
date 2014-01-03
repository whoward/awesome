require 'yajl'

class WebsocketProtocol

   def initialize(renderer)
      @renderer = renderer
   end

   ## Socket level protocol messages
   #############################################################################

   def protocol_error!(message)
      emit :error, message: message
   end

   def reconnect!(path)
      emit :reconnect, path: path
   end

   ## Session level protocol messages
   #############################################################################

   def identify!
      emit :identify
   end

   def set_session!(session)
      emit :session, token: session.token, username: session.user.login
   end

   def session_failure!(message)
      emit :session_failure, message: message
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

   ## Game level protocol messages
   #############################################################################

   def broadcast!(message)
      emit :broadcast, message: message
   end

   def display_talk!(sender, message)
      emit :talk, sender: sender, message: message
   end

   def display_private_message!(sender, message)
      emit :pm, sender: sender, message: message
   end

   def display_area!(area, players)
      emit :display_area, area: area.serialized_attributes.merge(players: players)
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

   def user_error!(message)
      emit :user_error, message: message
   end

   def undefined_direction!(message)
      emit :undefined_direction, message: message
   end

private
   attr_reader :renderer

   def emit(action, data={})
      renderer.render Yajl::Encoder.encode(data.merge(action: action))
   end
   
end