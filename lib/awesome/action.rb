require 'websocket_protocol'

module Awesome
   class Action < Cramp::Websocket
      UnhandledMessageError = Class.new(StandardError)

      on_start :connected
      on_finish :disconnected
      on_data :data_received

      def connected
         raise NotImplementedError
      end

      def disconnected
         raise NotImplementedError
      end

      def data_received(data)
         begin
            message = WebsocketMessage.parse(data)

            #TODO: use a state machine for session, if not validated then do not allow any action

            if respond_to?("handle_#{message.action}", false)
               send("handle_#{message.action}", message)
            else
               raise UnhandledMessageError
            end
         rescue WebsocketMessage::ParseError => e
            protocol.protocol_error! "malformed message"
            #TODO: use logger.debug instead
            puts "malformed message: #{data}"
         rescue UnhandledMessageError => e
            protocol.protocol_error! "unhandled message action: #{message.action.inspect}"
            #TODO: use logger.debug instead
            puts "unhandled message action: #{message.action.inspect}"
         end
      end

      def handle_session(data)
         SessionHandler.new(protocol, data).perform
      end

      def handle_login(data)
         LoginHandler.new(protocol, data).perform
      end

      def handle_register(data)
         RegisterHandler.new(protocol, data).perform
      end

   private

      def protocol
         @protocol ||= WebsocketProtocol.new(self)
      end

   end
end