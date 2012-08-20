require 'v8'
require 'pathname'

module Scripting
   class Context < V8::Context
      SourceRoot = Pathname.new(Awesome::App.root)
      
      def initialize(*args)
         super
         assign_globals!
      end

      def game
         @game ||= Scripting::Game.new
      end

      def console
         @console ||= Scripting::Console.new
      end

      def require(filename)
         file = SourceRoot.join(filename)

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