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

         def app_directories
            dirs = Pathname.new(root).join("app").children.select(&:directory?)
            dirs = dirs.reject {|x| x.basename.to_s =~ /^\./ }
            dirs
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

# add the "lib" directory to the load path
$:.unshift File.join(Awesome::App.root, "lib")

# add all subdirectories of "app" to the load path
Awesome::App.app_directories.each {|dir| $:.unshift(dir.to_s) }

# use bundler to ensure all 3rd party stuff is installed
Bundler.require(:default, Awesome::App.env)

#TODO: remove this crap
# load all files under the "app" and "lib" directory
Find.find(File.join Awesome::App.root, "lib") do |filename|
   require filename if File.extname(filename) == '.rb'
end

Find.find(File.join Awesome::App.root, "app") do |filename|
   require filename if File.extname(filename) == '.rb'
end