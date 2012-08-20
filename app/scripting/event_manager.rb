require 'set'

module Scripting
   class EventManager
      EventTypes = [:initialized, :player_joined, :player_left]

      def initialize
         @callbacks = Hash.new
      end

      EventTypes.each do |event|
         define_method("on#{event.to_s.classify}") do |callback|
            on(event, callback)
            nil
         end
      end

      #TODO: figure out how to hide this from javascript
      def notify(event, *args)
         (@callbacks[event] || []).each {|cb| cb.call(*args) }
         nil
      end

   private

      def on(event, callback)
         (@callbacks[event] ||= Set.new).add(callback)
      end

   end
end