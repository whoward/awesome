require 'logger'
require 'pathname'

module Awesome
   class App
      class << self

         # path to project root
         def root
            @root ||= File.expand_path("../..", File.dirname(__FILE__))
         end

         def app_directories
            dirs = Pathname.new(root).join("app").children.select(&:directory?)
            dirs = dirs.reject {|x| x.basename.to_s =~ /^\./ }
            dirs
         end

         def env
            ENV["RACK_ENV"] ||= "development"
         end

         def routes
            @routes ||= eval File.read("#{root}/config/routes.rb")
         end

         def logger
            @logger ||= Logger.new($stdout)
         end

         def log(message)
            logger.info(message) if env == "development"
         end

         # Initialize the application
         def initialize!
            Cramp::Websocket.backend = :thin

            Mongoid.load! File.join(root, "config", "mongoid.yml")
            Mongoid.allow_dynamic_fields = false

            if env == "development"
               User.logged_in.update_all(logged_in: false)
               Session.delete_all
            end

            Game.load_all!
         end
      end
   end
end
