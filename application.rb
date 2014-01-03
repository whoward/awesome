require 'bundler'
require 'find'

# add the "lib" directory to the load path
$:.unshift File.expand_path("lib", File.dirname(__FILE__))

require 'awesome/app'

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