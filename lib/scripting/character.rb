
module Scripting
   class Character

      # for now we will duck type users in as characters but i'm keeping this
      # semantically correct so javascript scripts don't need to be updated
      def initialize(character)
         @character = character
      end

      def name
         @character.login
      end

   end
end