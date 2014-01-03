require 'game_handler'

class TravelHandler < GameHandler

   def perform
      if next_area == nil
         conn.undefined_direction! "You canot go in that direction"
      else
         set_area!(next_area)
      end
   end

private
   hash_accessor :data, :direction
   
   def current_area
      @current_area ||= game.world.find_area_by_id(user.area_id)
   end

   def next_area
      @next_area ||= current_area.find_exit_by_name(direction)
   end

end