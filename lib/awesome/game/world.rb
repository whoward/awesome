
module Awesome
   module Game
      class World
         def self.parse(data)
            areas = []
            world = new(areas)
            data.each {|d| areas << Area.new(world, d) }
            world
         end

         attr_reader :areas

         def initialize(areas)
            @areas = areas
         end

         def find_area_by_id(id)
            areas.detect {|x| x.id == id }
         end

      end
   end
end