require 'awesome/already_connected_error'
require 'awesome/not_connected_error'

module Awesome
   class RedisChannel

      def initialize(hostname: "localhost", port: 6379)
         @hostname = hostname
         @port = port
         @callbacks = {}
      end

      def connected?
         !!connection
      end

      def connect
         begin
            connect!
         rescue AlreadyConnectedError => e
            false
         end
      end

      def connect!
         if connected?
            raise AlreadyConnectedError
         else
            connection = EM::Hiredis.connect("redis://#{hostname}:#{port}")
            connection.on(:message) do |event, message|
               callbacks[event].call(event, message)
            end
         end
      end

      def disconnect
         begin
            disconnect!
         rescue NotConnectedError => e
            false
         end
      end

      def disconnect!
         if connected?
            connection.close_connection
            connection = nil
         else
            raise NotConnectedError
         end
      end

      def publish(event, message)
         if connected?
            connection.publish(event, message)
         else
            raise NotConnectedError
         end
      end

      def subscribe(event, &callback)
         if connected?
            connection.subscribe(event) unless callbacks[event]
            callbacks[event] = callback
         else
            raise NotConnectedError
         end
      end

      def unsubscribe(event)
         if connected?
            connection.unsubscribe(event) if callbacks[event]
         else
            raise NotConnectedError
         end
      end

   private
      attr_reader :hostname, :port, :callbacks
      attr_writer :connection

   end
end