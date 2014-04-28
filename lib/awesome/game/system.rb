require 'pathname'

module Awesome
   module Game
      class System
      #    attr_reader :slug, :world

      #    def initialize(slug, directory)
      #       @slug = slug
      #       @directory = directory
      #       reload!
      #    end

      #    def shutdown!
      #       # shutdown the scripting engine
      #       scripting_engine.shutdown if @engine

      #       # unmemoize the data ivar
      #       @data = nil
      #    end

      #    def reload!
      #       shutdown!
            
      #       validate!

      #       # start up the scripting engine if the script exists
      #       if data.script and File.file?(File.join @directory, data.script)
      #          scripting_engine.load(data.script)
      #          event(:initialized)
      #       end
      #    end

      #    def validate!
      #       # force reparse of data file
      #       data

      #       # run through any data structures to enforce their loading/validation
      #       world
      #    end

      #    def name
      #       data.name
      #    end

      #    def description
      #       data.description
      #    end

      #    def version
      #       data.version
      #    end

      #    def starting_area
      #       world.find_area_by_id(starting_area_id)
      #    end

      #    def starting_area_id
      #       data.start_area_id
      #    end

      #    def world
      #       @world ||= Game::World.new(data.areas)
      #    end

      #    def scripting_engine
      #       @engine ||= Game::Scripting::Context.new(@directory)
      #    end

      #    def event(*args)
      #       scripting_engine.game.events.notify(*args)
      #    end

      # private
      #    def data
      #       @data ||= Game::DataFile.new File.join(@directory, 'game.json')
      #    end
      end
   end
end