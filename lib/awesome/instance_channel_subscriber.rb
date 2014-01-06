require 'awesome/channel_subscriber'

module Awesome
   class InstanceChannelSubscriber < ChannelSubscriber

      attr_reader :instance
      
      def initialize(instance, *args)
         super(*args)
         @instance = instance
      end

      def instance=(rhs)
         subscribed_events.each do |ev|
            resubscribe ev, ev.gsub("instance.#{instance.id}", "instance.#{rhs.id}")
         end

         @instance = rhs
      end

      def listen(*keys, &block)
         super(:instance, instance.id, *keys, &block)
      end

      def unlisten(*keys, &block)
         super(:instance, instance.id, *keys, &block)
      end
   end
end