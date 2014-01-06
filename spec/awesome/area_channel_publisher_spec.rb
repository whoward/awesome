require 'spec_helper'
require 'awesome/area_channel_publisher'

describe Awesome::AreaChannelPublisher do
   let(:logger) { Logger.new(File.open(File::NULL, "w")) }
   let(:channel) { ChannelMock.new }
   let(:instance) { double(id: "1A01") }
   let(:area) { double(id: "FF0F") }
   let(:publisher) { described_class.new(area, instance, channel, logger: logger) }

   it 'publishes to the user channel in a serialized data format' do
      publisher.publish :broadcast, message: "hiya"

      expect(channel.messages.length).to eq(1)

      event, data = channel.messages.first

      expect(event).to eql("instance.1A01.area.FF0F.broadcast")
      expect(data).to eq_json(message: "hiya")
   end

   it 'has a convenience method to notify of users entering the area' do
      publisher.travel_entry("fancypants", "1B01")

      expect(channel.messages.length).to eq(1)

      event, data = channel.messages.first

      expect(event).to eq("instance.1A01.area.FF0F.travel")
      expect(data).to eq_json(username: "fancypants", from_area_id: "1B01", to_area_id: "FF0F")
   end

   it 'has a convenience method to notify of users exiting the area' do
      publisher.travel_exit("fancypants", "1B01")

      expect(channel.messages.length).to eq(1)

      event, data = channel.messages.first

      expect(event).to eq("instance.1A01.area.FF0F.travel")
      expect(data).to eq_json(username: "fancypants", from_area_id: "FF0F", to_area_id: "1B01")
   end

end