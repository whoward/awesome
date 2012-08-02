# Running thin :
#
#   bundle exec thin --max-persistent-conns 1024 --timeout 0 -R config.ru start
#
# Vebose mode :
#
#   Very useful when you want to view all the data being sent/received by thin
#
#   bundle exec thin --max-persistent-conns 1024 --timeout 0 -V -R config.ru start
#

require './application'
require 'sprockets'

Awesome::App.initialize!

Tilt::CoffeeScriptTemplate.default_bare = true

# Development middlewares
if Awesome::App.env == 'development'
   use AsyncRack::CommonLogger

   # Enable code reloading on every request
   use Rack::Reloader, 0
end

map '/assets' do
   sprockets = Sprockets::Environment.new
   sprockets.append_path File.join(Awesome::App.root, 'assets', 'javascripts')
   sprockets.append_path File.join(Awesome::App.root, 'assets', 'stylesheets')

   run sprockets
end

map '/' do
   run Awesome::App.routes
end