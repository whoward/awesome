require 'bundler'
require 'find'

# add the "lib" directory to the load path
$:.unshift File.expand_path("lib", File.dirname(__FILE__))

require 'awesome/app'

# add all subdirectories of "app" to the load path
Awesome::App.app_directories.each {|dir| $:.unshift(dir.to_s) }

# use bundler to ensure all 3rd party stuff is installed
Bundler.require(:default, Awesome::App.env)