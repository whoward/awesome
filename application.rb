require 'rubygems'
require 'bundler'
require 'find'

module Awesome
   class App
      class << self

         # path to project root
         def root
            @root ||= File.dirname(__FILE__)
         end

         def env
            @env ||= ENV.fetch("RACK_ENV", "development")
         end

         def routes
            @routes ||= eval File.read("./config/routes.rb")
         end

         # Initialize the application
         def initialize!
            Cramp::Websocket.backend = :thin
         end
      end
   end
end

# use bundler to ensure all 3rd party stuff is installed
Bundler.require(:default, Awesome::App.env)

# load all files under the "app" directory
Find.find(File.join Awesome::App.root, "app") do |filename|
   require filename if File.extname(filename) == '.rb'
end
