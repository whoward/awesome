require 'hash_accessor'

class Handler
   extend HashAccessor

   def initialize(connection, data)
      @connection = connection
      @data = data
   end

protected
   attr_reader :connection
   alias :conn :connection

   attr_reader :data
end