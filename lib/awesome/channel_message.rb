
module Awesome
   class ChannelMessage
      ParseError = Class.new(StandardError)

      KnownKeys = %w(message sender username from_area_id to_area_id).freeze

      attr_reader :event, :data

      def self.parse(event, message)
         begin
            new(event, JSON.parse(message))
         rescue JSON::ParserError => e
            raise ParseError.new(e.message)
         end
      end

      def initialize(event, data)
         @event = event
         @data = data
      end

      KnownKeys.each do |key|
         define_method(key) { data[key] }
      end

      def [](key)
         data[key.to_s]
      end

      def to_str
         "#{event}: #{data}"
      end
      alias :to_s :to_str

   end
end