require 'spec_helper'
require 'awesome/websocket_message'

describe Awesome::WebsocketMessage do
   subject { described_class.new("action" => "hello", "username" => "me", "password" => "secret") }

   it 'has methods to access well known message keys' do
      expect(subject.action).to eq("hello")
      expect(subject.username).to eq("me")
      expect(subject.password).to eq("secret")
   end

   it 'can access using square brackets' do
      expect(subject["action"]).to eq("hello")
      expect(subject[:action]).to eq("hello")
   end

   it 'parses raw data' do
      expect(described_class.parse('{"action": "list"}').action).to eq("list")
   end

   it 'raises an error when given bad data' do
      expect(-> {
         described_class.parse('foo')
      }).to raise_error(Awesome::WebsocketMessage::ParseError)
   end

end