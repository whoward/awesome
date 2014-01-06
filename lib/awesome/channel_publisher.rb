require 'json'
require 'awesome/null_logger'

module Awesome
   class ChannelPublisher

      def initialize(channel, logger: NullLogger)
         @channel = channel
         @logger = logger
      end

      def publish(*keys, data)
         event = keys.join(".")
         message = JSON.dump(data)

         logger.info("pub[#{event}] #{data}")

         channel.publish(event, message)
      end

      def private_message(recipient_id, sender, message)
         publish :user, recipient_id, :pm, sender: sender, message: message
      end

   private
      attr_reader :channel, :logger
   
   end
end