require 'json'

module Awesome
   class Message
      ParseError = Class.new(StandardError)

      KnownKeys = %w(action username password token direction).freeze

      def self.parse(raw)
         begin
            new(JSON.parse(raw))
         rescue JSON::ParserError => e
            raise ParseError(e.message)
         end
      end

      def initialize(data)
         @data = data
      end

      def [](rhs)
         data[rhs.to_str]
      end

      KnownKeys.each do |key|
         define_method(key) { data[key] }
      end

   private
      attr_reader :data

   end
end