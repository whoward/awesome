require 'awesome/instance_channel_publisher'

module Awesome
   class AreaChannelPublisher < InstanceChannelPublisher

      attr_accessor :area

      def initialize(area, *args)
         super(*args)
         @area = area
      end

      def publish(*keys, data)
         super(:area, area.id, *keys, data)
      end

      def travel_entry(username, from_area_id)
         publish :travel, username: username, from_area_id: from_area_id, to_area_id: area.id
      end

      def travel_exit(username, to_area_id)
         publish :travel, username: username, from_area_id: area.id, to_area_id: to_area_id
      end
   end
end