require 'spec_helper'
require 'awesome/area_channel_subscriber'

describe Awesome::AreaChannelSubscriber do
   let(:logger) { Logger.new(File.open(File::NULL, "w")) }
   let(:channel) { ChannelMock.new(auto_flush: true) }
   let(:instance_a) { double(id: "FFFA") }
   let(:instance_b) { double(id: "FFFB") }
   let(:area_a) { double(id: "A101") }
   let(:area_b) { double(id: "B101") }
   let(:subscriber) { described_class.new(area_a, instance_a, channel, logger: logger) }

   it "subscribes under the scope of it's instance" do
      subscriber.listen(:travel) {}

      expect(subscriber.subscribed_events).to eq(["instance.FFFA.area.A101.travel"])
   end

   it "unsubscribes under the scope of it's instance" do
      callback = -> {}

      subscriber.listen(:travel, &callback)

      expect(subscriber.subscribed_events.length).to eq(1)

      subscriber.unlisten(:travel, &callback)

      expect(subscriber.subscribed_events.length).to eq(0)
   end

   context "#area=" do
      before { subscriber.listen(:travel) {} }

      it "reassigns the area" do
         subscriber.area = area_b
         expect(subscriber.area).to eq(area_b)
      end

      it "resubscribes to all listened events on the new area" do
         expect(subscriber.subscribed_events).to eq(["instance.FFFA.area.A101.travel"])
         subscriber.area = area_b
         expect(subscriber.subscribed_events).to eq(["instance.FFFA.area.B101.travel"])
      end
   end

   context "#instance=" do
      before { subscriber.listen(:travel) {} }
      
      it "resubscribes to all listened events on the new instance" do
         expect(subscriber.subscribed_events).to eq(["instance.FFFA.area.A101.travel"])
         subscriber.instance = instance_b
         expect(subscriber.subscribed_events).to eq(["instance.FFFB.area.A101.travel"])
      end
   end
end