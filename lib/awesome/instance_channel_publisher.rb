require 'awesome/channel_publisher'

module Awesome
   class InstanceChannelPublisher < ChannelPublisher

      attr_accessor :instance

      def initialize(instance, *args)
         super(*args)
         @instance = instance
      end

      def publish(*keys, data)
         super(:instance, instance.id, *keys, data)
      end

      def broadcast(message)
         publish :broadcast, message: message
      end

      def chat(sender, message)
         publish :chat, message: message, sender: sender
      end
   end
end