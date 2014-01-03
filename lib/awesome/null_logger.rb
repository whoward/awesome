
module Awesome
   module NullLogger
      extend self

      %w(fatal error warn info debug).each do |level|
         define_method(level) do |*args|
            # no-op
         end
      end

   end
end