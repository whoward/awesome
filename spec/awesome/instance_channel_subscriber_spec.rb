require 'spec_helper'
require 'awesome/instance_channel_subscriber'

describe Awesome::InstanceChannelSubscriber do
   let(:logger) { Logger.new(File.open(File::NULL, "w")) }
   let(:channel) { ChannelMock.new(auto_flush: true) }
   let(:instance_a) { double(id: "A101") }
   let(:instance_b) { double(id: "B101") }
   let(:subscriber) { described_class.new(instance_a, channel, logger: logger) }

   it "subscribes under the scope of it's instance" do
      subscriber.listen(:broadcast) {}

      expect(subscriber.subscribed_events).to eq(["instance.A101.broadcast"])
   end

   it "unsubscribes under the scope of it's instance" do
      callback = -> {}

      subscriber.listen(:broadcast, &callback)

      expect(subscriber.subscribed_events.length).to eq(1)

      subscriber.unlisten(:broadcast, &callback)

      expect(subscriber.subscribed_events.length).to eq(0)
   end

   context "#instance=" do
      before { subscriber.listen(:broadcast) {} }

      it "reassigns the instance" do
         subscriber.instance = instance_b
         expect(subscriber.instance).to eq(instance_b)
      end

      it "resubscribes to all listened events on the new instance" do
         expect(subscriber.subscribed_events).to eq(["instance.A101.broadcast"])
         subscriber.instance = instance_b
         expect(subscriber.subscribed_events).to eq(["instance.B101.broadcast"])
      end
   end
end