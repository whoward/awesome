require 'spec_helper'
require 'awesome/channel_subscriber'

describe Awesome::ChannelSubscriber do
   let(:logger) { Logger.new(File.open(File::NULL, "w")) }
   let(:channel) { ChannelMock.new(auto_flush: true) }
   let(:subscriber) { described_class.new(channel, logger: logger) }

   it 'subscribes to the channel given by the keys' do
      expect(channel).to receive(:subscribe).with("instance.123.broadcast")

      subscriber.listen(:instance, 123, :broadcast) {}
   end

   it 'does not resubscribe to the same channel' do
      expect(channel).to receive(:subscribe).once

      subscriber.listen(:instance, 123, :broadcast) {}
      subscriber.listen(:instance, 123, :broadcast) {}
   end

   it 'logs the first time it subscribes to a channel' do
      expect(logger).to receive(:info).once

      subscriber.listen(:foo) {}
      subscriber.listen(:foo) {}
   end

   it 'logs when receiving a message on a channel it is subscribed to' do
      subscriber.listen(:instance, 123, :broadcast) {}
      subscriber.listen(:instance, 456, :broadcast) {}

      expect(logger).to receive(:info).once

      channel.publish("instance.123.broadcast", '{"message":"hello world!"}')
   end

   it 'logs an error when receiving a malformed message' do
      subscriber.listen(:instance, 123, :broadcast) {}

      expect(logger).to receive(:error).once

      channel.publish("instance.123.broadcast", '{"message": }')
   end

   context "#subscribed_events" do
      it "provides a method to list all events it's subscribed to" do
         subscriber.listen(:instance, 123, :broadcast) {}
         subscriber.listen(:instance, 456, :broadcast) {}

         expect(subscriber.subscribed_events).to eq(["instance.123.broadcast", "instance.456.broadcast"])
      end

      it "does not include events which no longer have listeners" do
         callback = -> {}

         subscriber.listen(:instance, 123, :broadcast, &callback)
         subscriber.unlisten(:instance, 123, :broadcast, &callback)

         expect(subscriber.subscribed_events).to eq([])
      end
   end

   context "when subscribed" do
      let(:listener_a) { -> ev {} }
      let(:listener_b) { -> ev {} }
      let(:listener_c) { -> ev {} }

      before do
         subscriber.listen(:instance, 123, :broadcast, &listener_a)
         subscriber.listen(:instance, 123, :broadcast, &listener_b)
         subscriber.listen(:user, 456, :pm, &listener_c)
      end

      it 'notifies all listeners when receiving a matching event' do
         expect(listener_a).to receive(:call).once
         expect(listener_b).to receive(:call).once
         expect(listener_c).not_to receive(:call)

         channel.publish("instance.123.broadcast", '{"message":"hello world!"}')
      end

      it 'allows unlistening from channels' do
         subscriber.unlisten(:instance, 123, :broadcast, &listener_a)

         expect(listener_a).not_to receive(:call)

         channel.publish("instance.123.broadcast", '{"message":"hello world!"}')
      end

      it 'unsubscribes from the channel' do
         expect(channel).to receive(:unsubscribe).with("instance.123.broadcast")

         subscriber.unlisten("instance.123.broadcast", &listener_a)
         subscriber.unlisten("instance.123.broadcast", &listener_b)
      end

      it 'logs when unsubscribing from the channel' do
         expect(logger).to receive(:info).once

         subscriber.unlisten("instance.123.broadcast", &listener_a)
         subscriber.unlisten("instance.123.broadcast", &listener_b)
      end
   end
end