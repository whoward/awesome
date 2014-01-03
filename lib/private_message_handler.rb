require 'game_handler'

class PrivateMessageHandler < GameHandler

   def perform
      if recipient == nil
         conn.error_message! "#{username} is not logged in"
      else
         pubsub.private_message(recipient.id, user.login, message)
      end
   end

private
   hash_accessor :data, :username, :message

   def recipient
      @recipient ||= User.logged_in.where(login: username).first
   end

end