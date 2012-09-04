
module Scripting
   class Game

      def initialize
         @timers = {}
         @timer_last_called = {}
      end

      def events
         @event_manager ||= Scripting::EventManager.new
      end

      def instance
         Scripting::Instance.new(::Instance.main_instance)
      end

      def addTimer(milliseconds, callback)
         id = next_timer_id
         EventMachine.next_tick { add_timer id, EventMachine::Timer, milliseconds, callback }
         id #TODO: look up what the issue is converting this back to javascript
      end

      def addPeriodicTimer(milliseconds, callback)
         id = next_timer_id
         EventMachine.next_tick { add_timer id, EventMachine::PeriodicTimer, milliseconds, callback }
         id #TODO: look up what the issue is converting this back to javascript
      end

      def cancelTimer(id)
         timer = @timers[id]

         if timer
            timer.cancel
            @timer_last_called.delete(id)
            true
         else
            false
         end
      end
   
   private
      def next_timer_id
         @next_timer_id ||= 0
         @next_timer_id += 1
      end

      def add_timer(id, klass, milliseconds, callback)
         # calculate the seconds and initialize the timer
         seconds = milliseconds.to_f / 1000.0
         
         timer = klass.new(seconds) do
            # calculate the number of milliseconds since the last time it was called
            now = Time.now.to_f

            elapsed_time = (now - @timer_last_called[id]) * 1000

            callback.call(elapsed_time)

            # if this was a one shot timer then remove the reference, otherwise
            # update the "last called time" in the hash
            if klass == EventMachine::Timer
               @timer_last_called.delete(id)
            else
               @timer_last_called[id] = now
            end
         end

         # keep track of the timer so we can cancel them later
         @timers[id] = timer

         @timer_last_called[id] = Time.now.to_f

         # return the timer object
         timer
      end

   end
end