require 'handler'

class GameHandler < Handler

   def initialize(connection, data, game, session, pubsub)
      super(connection, data)
      @game = game
      @session = session
      @pubsub = pubsub
   end

protected
   attr_reader :game, :session, :pubsub

   def user
      session.user
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
      conn.display_area! area, players
   end

end