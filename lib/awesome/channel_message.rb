
module Awesome
   class ChannelMessage
      ParseError = Class.new(StandardError)

      def self.parse(event, message)
         begin
            new(event, JSON.parse(message))
         rescue JSON::ParserError => e
            raise ParseError(e.message)
         end
      end

      def initialize(event, data)
         @event = event
         @data = data
      end

      def to_str
         "#{event}: #{data}"
      end

      def to_params
         case event
         when "broadcast" then data.values_at("message")
         when "chat" then data.values_at("sender", "message")
         when "pm" then data.values_at("sender", "message")
         when "travel" then data.values_at("username", "from_area_id", "to_area_id")
         end
      end

   private
      attr_reader :event, :data

   end
end