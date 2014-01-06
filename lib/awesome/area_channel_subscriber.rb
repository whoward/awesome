require 'awesome/instance_channel_subscriber'

module Awesome
   class AreaChannelSubscriber < InstanceChannelSubscriber

      attr_reader :area
      
      def initialize(area, *args)
         super(*args)
         @area = area
      end

      def area=(rhs)
         subscribed_events.each do |ev|
            resubscribe ev, ev.gsub("area.#{area.id}", "area.#{rhs.id}")
         end

         @area = rhs
      end

      def listen(*keys, &block)
         super(:area, area.id, *keys, &block)
      end

      def unlisten(*keys, &block)
         super(:area, area.id, *keys, &block)
      end
   end
end