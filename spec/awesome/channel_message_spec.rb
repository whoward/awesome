require 'spec_helper'
require 'awesome/channel_message'

describe Awesome::ChannelMessage do
   subject { described_class.new("broadcast", "message" => "hello world!", "sender" => "awesomeness") }

   it 'has methods to access well known message keys' do
      expect(subject.message).to eq("hello world!")
      expect(subject.sender).to eq("awesomeness")
   end

   it 'can access using square brackets' do
      expect(subject["message"]).to eq("hello world!")
      expect(subject[:message]).to eq("hello world!")
   end

   it 'parses raw data' do
      msg = described_class.parse("broadcast", '{"message": "hello world!"}')

      expect(msg.event).to eq("broadcast")
      expect(msg.message).to eq("hello world!")
   end

   it 'raises an error when given bad data' do
      expect(-> {
         described_class.parse('foo', 'foo')
      }).to raise_error(Awesome::ChannelMessage::ParseError)
   end

   it 'can stringify itself' do
      expect(subject.to_str).to eq('broadcast: {"message"=>"hello world!", "sender"=>"awesomeness"}')
   end

end