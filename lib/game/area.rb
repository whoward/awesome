
module Game
   class Area
      attr_reader :id, :name, :description, :exits, :players

      def initialize(data, world)
         @world = world

         @id = data["id"]
         @name = data["name"]
         @description = data["description"]
         @exits = data["exits"]
      end

      def find_exit_by_id(id)
         (exits || {}).detect {|name,exit_id| exit_id == id }.try(:first)
      end

      def find_exit_by_name(name)
         exit_id = (exits || {}).fetch(name, nil)

         if exit_id
            @world.find_area_by_id(exit_id)
         else
            nil
         end
      end

      def exits_with_names
         result = exits.map do |name, id|
            area = find_exit_by_name(name)

            if area
               [name, area.name]
            else
               [name, "Unknown Area"]
            end
         end

         Hash[result]
      end

      def serialized_attributes
         {
            :name => name,
            :description => description,
            :exits => exits_with_names
         }
      end
   end
end