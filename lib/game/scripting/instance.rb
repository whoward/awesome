
module Game::Scripting
   class Instance

      def initialize(instance)
         @instance = instance
      end

      def broadcast(message)
         pubsub.broadcast(message)
      end

      def chat(sender, message)
         pubsub.chat(sender, message)
      end

   private

      def pubsub
         @pubsub ||= InstancePubSubClient.new(@instance.id)
      end

   end
end