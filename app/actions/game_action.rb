
class GameAction < Cramp::Websocket
   include GameWebSocketHandler

   include SessionSocketProtocol
   include GameSocketProtocol

   on_start :connected
   on_finish :disconnected
   on_data :data_received
   
   def connected
      puts "connected to game with params: #{params.inspect}"

      @game = Game.find_by_slug(params[:slug])

      if @game
         identify!
      else
         user_error! "Can not find a game to connect to on this channel"
      end
   end
   
   def disconnected
      if user
         user.logout!

         @game.event(:player_left, Game::Scripting::Character.new(user))
      end

      pubsub.disconnect!
   end

   def handle_travel(data)
      current_area = @game.world.find_area_by_id(user.area_id)
      next_area = current_area.find_exit_by_name(data[:direction])

      if next_area == nil
         return undefined_direction! "You canot go in that direction"
      end

      set_area!(next_area)
   end
   
   def handle_talk(data)
      pubsub.chat(user.login, data[:message])
   end

   def handle_pm(data)
      recipient = User.logged_in.where(:login => data[:username]).first

      if recipient == nil
         return error_message! "#{data[:username]} is not logged in"
      end

      pubsub.private_message(recipient.id, user.login, data[:message])
   end

   def handle_list(data)
      user_list! User.in_instance(user.instance).only(:login).map(&:login)
   end
   
private
   def session_created(session)
      @session = session

      puts @session.inspect
      puts @session.user.inspect

      user.instance = Instance.main_instance
      user.save!

      subscribe!

      @game.event(:player_joined, Game::Scripting::Character.new(user))

      current_area = user.area_id ? @game.world.find_area_by_id(user.area_id) : @game.starting_area

      set_area!(current_area)
   end

   def subscribe!
      pubsub.on_broadcast do |message|
         broadcast! message
      end

      pubsub.on_chat do |sender, message|
         display_talk! sender, message
      end

      pubsub.on_private_message do |sender, message|
         display_private_message! sender, message
      end

      pubsub.on_area_travel do |travelling_user, from_area_id, to_area_id|
         # ignore travel messages from this user
         if travelling_user != user.login
            if from_area_id == user.area_id
               # user is exiting the area
               direction = user.area.find_exit_by_id(to_area_id)

               player_leaves_area! travelling_user, direction
            else
               # user is entering the area
               direction = user.area.find_exit_by_id(from_area_id)

               player_enters_area! travelling_user, direction
            end
         end
      end
   end

   def set_area!(area)
      # notify other players of the user's movement
      pubsub.area_travel(user.login, user.area_id, area.id)

      # update the database record for the user's area
      user.area_id = area.id
      user.save!

      # change the area we receive event notifications from
      pubsub.area = area

      # get a list of player names in the area
      players = User.in_instance(user.instance).in_area(area).only(:login).map(&:login)

      # finally send the command to display the new area
      display_area! area, players
   end

   def user
      @session.try(:user)
   end

   def pubsub
      @pubsub ||= UserPubSubClient.new(user)
   end

end