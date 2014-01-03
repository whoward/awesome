require 'forwardable'

module Awesome
   class KeyedEventChannel
      extend Forwardable

      def_delegators :@channel, :connected?, :connect, :connect!, :disconnect, :disconnect!

      def initialize(channel)
         @channel = channel
      end

      def publish(event, message)

      end

      def subscribe(event, &callback)

      end

      def unsubscribe(event)

      end


   private
      attr_reader :channel

   end
end