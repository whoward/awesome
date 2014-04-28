
module Awesome
   module Game
      class Area
         InvalidAreaError = Class.new(StandardError)

         attr_reader :id, :name, :description, :exits

         def initialize(world, data)
            @world = world

            @id          = data.fetch("id") { raise InvalidAreaError.new("missing required attribute ID") }
            @name        = data.fetch("name", "[untitled area]")
            @description = data.fetch("description", "[missing description]")
            @exits       = data.fetch("exits", {})
         end

         def find_exit_name_by_id(id)
            exits.detect {|name,exit_id| exit_id == id }.try(:first)
         end

         def find_exit_id_by_name(name)
            exits[name]
         end

         def find_neighbour_by_name(name)
            if exit_id = find_exit_id_by_name(name)
               world.find_area_by_id(exit_id)
            else
               nil
            end
         end

         def exits_with_names
            result = exits.map do |name, id|
               area = find_neighbour_by_name(name)

               if area
                  [name, area.name]
               else
                  [name, "[unknown area]"]
               end
            end

            Hash[result]
         end
         
         def to_websocket_protocol
            {
               "name" => name,
               "description" => description,
               "exits" => exits_with_names
            }
         end

      private
         attr_reader :world

      end
   end
end