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
            ENV["RACK_ENV"] ||= "development"
         end

         def routes
            @routes ||= eval File.read("./config/routes.rb")
         end

         def log(message)
            puts(message) if env == "development"
         end

         def scripting_engine
            @engine ||= Scripting::Context.new
         end

         # Initialize the application
         def initialize!
            Cramp::Websocket.backend = :thin

            Mongoid.load! File.join(root, "config", "mongoid.yml")
            Mongoid.allow_dynamic_fields = false

            User.logged_in.update_all(logged_in: false) if env == "development"

            scripting_engine.require("game.js")
            scripting_engine.game.events.notify(:initialized)
         end
      end
   end
end

$:.unshift File.join(Awesome::App.root, "lib")

# use bundler to ensure all 3rd party stuff is installed
Bundler.require(:default, Awesome::App.env)

# load all files under the "app" and "lib" directory
Find.find(File.join Awesome::App.root, "lib") do |filename|
   require filename if File.extname(filename) == '.rb'
end

Find.find(File.join Awesome::App.root, "app") do |filename|
   require filename if File.extname(filename) == '.rb'
end