
module Game
   class World
      attr_reader :data

      def initialize(data)
         @data = data

         # force parsing of areas to ensure validation
         areas
      end

      def areas
         @areas ||= data.map {|id, data| Game::Area.new(data, self) }
      end

      def find_area_by_id(id)
         #TODO: consider a data structure later for faster lookup
         areas.detect {|x| x.id == id }
      end

   end
end