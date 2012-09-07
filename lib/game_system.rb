require 'pathname'
require 'lib/game_data_file'
require 'lib/world'
require 'lib/scripting'

class GameSystem
   Root = File.join(Awesome::App.root, "games")

   def self.all
      @all ||= []
   end

   #TODO: move to game.rb
   def self.load_all!
      #TODO: clean existing game systems out

      # select files in the directory
      games = Pathname.new(Root).children.select(&:directory?)

      # reject unix hidden files from the file list
      games = games.reject {|x| x.basename.to_s =~ /^\./ }

      # get a list of directory names with invalid characters
      invalid = games.reject {|x| x.basename.to_s =~ /^[a-zA-Z\-]+$/}

      if invalid.any?
         STDERR.puts "the following game systems have invalid names and will not be imported:"
         invalid.each {|x| puts "\t" + x.basename.to_s }
      end

      # load all other games
      (games - invalid).each do |path|
         self.all << GameSystem.new(path.basename.to_s)
      end

      # return all game systems
      self.all
   end

   attr_reader :slug, :world

   def initialize(slug)
      @slug = slug
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
      @world ||= World.new(data.areas)
   end

   def scripting_engine
      @engine ||= Scripting::Context.new
   end

private
   def data
      @data ||= lambda do
         begin
            GameDataFile.new File.join(Root, 'game.json')
         rescue Exception => e
            STDERR.puts "Error while loading game system: #{@slug}"
            STDERR.puts e.backtrace.join("\n")
            {}
         end
      end.call
   end

end