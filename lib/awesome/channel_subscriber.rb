require 'set'
require 'json'
require 'null_logger'

module Awesome
   class ChannelSubscriber
      
      def initialize(channel, logger: NullLogger)
         @channel = channel
         @logger = logger
         @listeners = Hash.new {|h,k| h[k] = Set.new }
      end

      def listen(*keys, &block)
         event = keys.join(".")

         if listeners[event].empty?
            logger.info("sub[#{event}] #{block.object_id}")
            channel.subscribe(event, &method(:message))
         end

         listeners[event].add(block)
      end

      def unlisten(*keys, &block)
         event = keys.join(".")

         listeners[event].delete(block)

         if listeners[event].empty?
            logger.info("unsub[#{event}] #{block.object_id}")
            channel.unsubscribe(event)
         end
      end

   protected

      def message(event, data)
         begin
            message = ChannelMessage.parse(event, data)

            logger.info("#{event} #{data}")

            listeners[event].each {|l| l.call(*message.to_params) }
         rescue ChannelMessage::ParseError => e
            logger.error("subscription parse error: #{e.message}")
         end
      end

   private
      attr_reader :channel, :logger, :listeners

   end
end