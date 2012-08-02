require 'erb'

class HomeAction < Cramp::Action
   IndexTemplateFile = File.join(Awesome::App.root, 'app/views/index.erb')

   def start
      render ERB.new(File.read(IndexTemplateFile)).result(binding)
      finish
   end
end