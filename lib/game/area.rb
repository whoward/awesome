
module Game
   class Area
      include ActiveAttr::Model

      attribute :id
      attribute :name
      attribute :description
      attribute :exits
      attribute :players

      def self.find_by_id(id, world=World.instance)
         world.find_area_by_id(id)
      end

      class << self
         alias :find :find_by_id
      end

      def find_exit_by_id(id)
         (exits || {}).detect {|name,exit_id| exit_id == id }.try(:first)
      end

      def find_exit_by_name(name, world=World.instance)
         exit_id = (exits || {}).fetch(name, nil)

         if exit_id
            Area.find_by_id(exit_id)
         else
            nil
         end
      end

      def exits_with_names(world=World.instance)
         result = exits.map do |name, id|
            exit_name = find_exit_by_name(name, world).name
            
            [name, exit_name]
         end

         Hash[result]
      end

      def serialized_attributes(world=World.instance)
         {
            :name => name,
            :description => description,
            :players => players,
            :exits => exits_with_names(world)
         }
      end
   end
end