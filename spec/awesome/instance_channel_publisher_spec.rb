require 'spec_helper'
require 'awesome/instance_channel_publisher'

describe Awesome::InstanceChannelPublisher do
   let(:logger) { Logger.new(File.open(File::NULL, "w")) }
   let(:channel) { ChannelMock.new }
   let(:instance) { double(id: "1A01") }
   let(:publisher) { described_class.new(instance, channel, logger: logger) }

   it 'publishes to the instance channel in a serialized data format' do
      publisher.publish :broadcast, message: "hello world!"

      expect(channel.messages.length).to eq(1)

      event, data = channel.messages.first

      expect(event).to eql("instance.1A01.broadcast")
      expect(data).to eql('{"message":"hello world!"}')
   end

   it 'has a convenience method to broadcast a message' do
      publisher.broadcast "hello world!"

      expect(channel.messages.length).to eq(1)

      event, data = channel.messages.first

      expect(event).to eql("instance.1A01.broadcast")
      expect(data).to eql('{"message":"hello world!"}')
   end

   it 'has a convenience method to publish a chat message' do
      publisher.chat "fancypants", "hows it going"

      expect(channel.messages.length).to eq(1)

      event, data = channel.messages.first

      expect(event).to eql("instance.1A01.chat")
      expect(data).to eql('{"message":"hows it going","sender":"fancypants"}')
   end
end