
module Scripting
   class Game

      def events
         @event_manager ||= Scripting::EventManager.new
      end

   end
end