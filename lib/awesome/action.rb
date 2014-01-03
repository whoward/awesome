require 'websocket_protocol'

module Awesome
   class Action < Cramp::Websocket

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
         #TODO: security error here (should never symbolize untrusted data)
         #TODO: don't just rescue an empty hash - handle that damn error
         msg = Yajl::Parser.parse(data, symbolize_keys: true) rescue {}

         handler_method = "handle_#{msg[:action]}"

         #TODO: use a state machine for session, if not validated then do not allow any action

         if respond_to?(handler_method, false)
            send(handler_method, msg)
         else
            puts "unhandled message action: #{msg[:action].inspect}"
            #TODO: actually do something - don't just fail silently
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