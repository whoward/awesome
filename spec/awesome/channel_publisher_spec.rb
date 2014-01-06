require 'spec_helper'
require 'awesome/channel_publisher'

describe Awesome::ChannelPublisher do
   let(:logger) { Logger.new(File.open(File::NULL, "w")) }
   let(:channel) { ChannelMock.new }
   let(:publisher) { described_class.new(channel, logger: logger) }

   it 'publishes to the channel in a serialized data format' do
      publisher.publish :instance, 123, :broadcast, message: "hello world!"

      expect(channel.messages.length).to eq(1)

      event, data = channel.messages.first

      expect(event).to eql("instance.123.broadcast")
      expect(data).to eql('{"message":"hello world!"}')
   end

   it 'allows passing a logger to which it will log to' do
      expect(logger).to receive(:info).once
      publisher.publish :instance, 123, :broadcast, message: "hello world!"
   end

   it 'has a convenience method to deliver a private message' do
      publisher.private_message "10A1", "fancypants", "whats up buddy?"

      expect(channel.messages.length).to eq(1)

      event, data = channel.messages.first

      expect(event).to eql("user.10A1.pm")
      expect(data).to eq_json(message: "whats up buddy?", sender: "fancypants")
   end
end