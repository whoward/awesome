require 'singleton'

class World
   include Singleton

   def areas
      @areas ||= data["world"].map {|id, data| Area.new(data) }
   end

   def find_area_by_id(id)
      #TODO: consider a data structure later for faster lookup
      areas.detect {|x| x.id == id }
   end

private

   def data
      @data ||= Yajl::Parser.parse(File.read(data_file))
   end

   def data_file
      File.join(Awesome::App.root, 'game.json')
   end
end