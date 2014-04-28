require 'singleton'
require 'awesome/game/area'

class WorldDouble
   include Singleton

   def areas
      DATA.values
   end

   def find_area_by_id(id)
      DATA[id]
   end

private

   DATA = {
      "1-01" => Awesome::Game::Area.new(instance, 
         "id" => "1-01",
         "name" => "Campfire",
         "description" => "Description for Campfire",
         "exits" => {
            "North" => "1-02",
            "South" => "1-03"
         }
      ),
      "1-02" => Awesome::Game::Area.new(instance, 
         "id" => "1-02",
         "name" => "Abandoned Shoppe",
         "description" => "Description for Abandoned Shoppe",
         "exits" => {
            "South" => "1-01"
         }
      ),
      "1-03" => Awesome::Game::Area.new(instance, 
         "id" => "1-03",
         "name" => "Fiery Pit",
         "description" => "Description for Fiery Pit",
         "exits" => {
            "North" => "1-01"
         }
      )
   }
end

describe WorldDouble do
   it_behaves_like "a world", WorldDouble.instance
end