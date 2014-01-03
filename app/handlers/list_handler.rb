require 'game_handler'

class ListHandler < GameHandler

   def perform
      conn.user_list! User.in_instance(user.instance).only(:login).map(&:login)
   end

end