# require 'pathname'

module Awesome
   module Game
      # GameRoot = File.join(Awesome::App.root, "games")

      # def self.all
      #    @all ||= []
      # end

      # def self.find_by_slug(slug)
      #    all.detect {|game| game.slug == slug }
      # end

      # def self.load_all!
      #    #TODO: clean existing game systems out

      #    # select files in the directory
      #    games = Pathname.new(GameRoot).children.select(&:directory?)

      #    # reject unix hidden files from the file list
      #    games = games.reject {|x| x.basename.to_s =~ /^\./ }

      #    # get a list of directory names with invalid characters
      #    invalid = games.reject {|x| x.basename.to_s =~ /^[a-zA-Z\-]+$/}

      #    if invalid.any?
      #       STDERR.puts "the following game systems have invalid names and will not be imported:"
      #       invalid.each {|x| puts "\t" + x.basename.to_s }
      #    end

      #    # load all other games
      #    (games - invalid).each do |path|
      #       begin
      #          self.all << Game::System.new(path.basename.to_s, path)
      #       rescue Exception => e
      #          STDERR.puts "Error while loading game system: #{@slug}"
      #          STDERR.puts e.message
      #          STDERR.puts e.backtrace.join("\n")
      #       end
      #    end

      #    # return all game systems
      #    self.all
      # end

      # def self.find_by_slug(slug)
      #    all.detect {|game| game.slug == slug }
      # end

   end
end

# require 'game/system'
# require 'game/data_file'
# require 'game/world'
# require 'game/area'
# require 'game/scripting'