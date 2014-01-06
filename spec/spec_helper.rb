require File.expand_path("../application", File.dirname(__FILE__))

Dir.glob("#{File.dirname(__FILE__)}/shared/**/*.rb").each {|f| require f }

Dir.glob("#{File.dirname(__FILE__)}/support/**/*.rb").each {|f| require f }