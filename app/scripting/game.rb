
module Scripting
   class Game

      def events
         @event_manager ||= Scripting::EventManager.new
      end

      def instance
         Scripting::Instance.new(::Instance.main_instance)
      end
   end
end