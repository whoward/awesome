require 'socket_protocol'

module GameSocketProtocol
   include SocketProtocol

   # no public methods

private

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
      data = area.serialized_attributes.merge(:players => players)

      emit :display_area, area: data
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
end