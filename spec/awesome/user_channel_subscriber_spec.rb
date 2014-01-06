require 'spec_helper'
require 'awesome/user_channel_subscriber'

describe Awesome::UserChannelSubscriber do
   let(:logger) { Logger.new(File.open(File::NULL, "w")) }
   let(:channel) { ChannelMock.new(auto_flush: true) }
   let(:user_a) { double(id: "U100") }
   let(:user_b) { double(id: "U101") }
   let(:subscriber) { described_class.new(user_a, channel, logger: logger) }

   it "subscribes under the scope of it's instance" do
      subscriber.listen(:pm) {}

      expect(subscriber.subscribed_events).to eq(["user.U100.pm"])
   end

   it "unsubscribes under the scope of it's instance" do
      callback = -> {}

      subscriber.listen(:pm, &callback)

      expect(subscriber.subscribed_events.length).to eq(1)

      subscriber.unlisten(:pm, &callback)

      expect(subscriber.subscribed_events.length).to eq(0)
   end

   context "#user=" do
      before { subscriber.listen(:pm) {} }

      it "reassigns the user" do
         subscriber.user = user_b
         expect(subscriber.user).to eq(user_b)
      end

      it "resubscribes to all listened events on the new user" do
         expect(subscriber.subscribed_events).to eq(["user.U100.pm"])
         subscriber.user = user_b
         expect(subscriber.subscribed_events).to eq(["user.U101.pm"])
      end
   end
end