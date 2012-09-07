require 'pathname'

module Game
   class System
      attr_reader :slug, :world

      def initialize(slug, directory)
         @slug = slug
         @directory = directory
         reload!
      end

      def shutdown!
         # shutdown the scripting engine
         scripting_engine.shutdown if @engine

         # unmemoize the data ivar
         @data = nil
      end

      def reload!
         shutdown!
         
         # force reparse of data file
         data

         # run through any data structures to enforce their loading/validation
         world

         # start up the scripting engine if the script exists
         if data.script and File.file?(data.script)
            scripting_engine.load(data.script)
            scripting_engine.game.events.notify(:initialized)
         end
      end

      def name
         data.name
      end

      def description
         data.description
      end

      def version
         data.version
      end

      def starting_area_id
         data.start_area_id
      end

      def world
         @world ||= Game::World.new(data.areas)
      end

      def scripting_engine
         @engine ||= Game::Scripting::Context.new(@directory)
      end

   private
      def data
         @data ||= lambda do
            begin
               Game::DataFile.new File.join(@directory, 'game.json')
            rescue Exception => e
               STDERR.puts "Error while loading game system: #{@slug}"
               STDERR.puts e.backtrace.join("\n")
               {}
            end
         end.call
      end
   end
end