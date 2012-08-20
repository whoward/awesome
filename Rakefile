
task "console" do
   #TODO: execute Awesome::App.initialize
   system "irb -I #{File.dirname(__FILE__)} -r 'application'"
end

task "server" do
   system "bundle exec thin --max-persistent-conns 1024 --timeout 0 -V -R #{File.dirname(__FILE__)}/config.ru start"
end