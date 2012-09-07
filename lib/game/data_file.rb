
module Game
   class DataFile

      def initialize(filename)
         @filename = filename

         load
      end

      def name
         data["name"]
      end

      def description
         data.fetch("description", "")
      end

      def version
         data["version"]
      end

      def script
         data["script"]
      end

      def start_area_id
         data["start_area"]
      end

      def areas
         data.fetch("world", {})
      end

   private

      def load
         # the following is all required data
         raise 'missing data: name' if name == nil
         raise 'missing data: version' if version == nil
         raise 'missing data: start_area' if start_area_id == nil

         # ensure the starting area is actually defined
         raise "starting area #{start_area} is not defined" if areas[start_area_id] == nil
      end

      def data
         @data ||= Yajl::Parser.parse(File.read(@filename))
      end

   end
end