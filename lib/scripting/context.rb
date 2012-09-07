require 'v8'
require 'pathname'

module Scripting
   class Context < V8::Context

      def initialize(source_root, *args)
         super(*args)
         
         @source_root = Pathname.new(source_root)

         assign_globals!
      end

      def shutdown
         game.events.notify(:shutdown)
         @timers.each(&:cancel)
         @timer_last_called.delete_if { true }
      end

      def game
         @game ||= Scripting::Game.new
      end

      def console
         @console ||= Scripting::Console.new
      end

      def load(filename)
         file = @source_root.join(filename)

         #TODO: ensure the file is readable and is not outside the source root directory
         if file.file?
            eval file.read
            true
         else
            false
         end
      end

   private
      def assign_globals!
         self['game'] = game
         self['console'] = console
      end

   end
end