require 'game_handler'

class TalkHandler < GameHandler

   def perform
      pubsub.chat(user.login, message)
   end

private
   hash_accessor :data, :message

end