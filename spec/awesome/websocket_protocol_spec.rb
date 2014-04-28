require 'spec_helper'
require 'awesome/websocket_protocol'
require 'session'

describe Awesome::WebsocketProtocol do
   let(:output) { String.new }
   let(:renderer) { RendererDouble.new(output) }
   let(:proto) { described_class.new(renderer) }

   it 'renders a protocol error' do
      proto.protocol_error! "no go"
      expect(output).to eq_json(action: "error", message: "no go")
   end

   it 'renders a reconnect instruction' do
      proto.reconnect! "/foo/bar"
      expect(output).to eq_json(action: "reconnect", path: "/foo/bar")
   end

   it 'renders an identify instruction' do
      proto.identify!
      expect(output).to eq_json(action: "identify")
   end

   it 'renders a session instruction' do
      proto.set_session! double(token: "hello", user: double(login: "fancypants"))
      expect(output).to eq_json(action: "session", token: "hello", username: "fancypants")
   end

   it 'renders a session error' do
      proto.session_failure! "zomg"
      expect(output).to eq_json(action: "session_failure", message: "zomg")
   end

   it 'renders a login error' do
      proto.login_failure! "ZOMG"
      expect(output).to eq_json(action: "login_failure", message: "ZOMG")
   end

   it 'renders a login success' do
      proto.login_success! "w00t!"
      expect(output).to eq_json(action: "login_success", message: "w00t!")
   end

   it 'renders a registration error' do
      proto.register_failure! "aww"
      expect(output).to eq_json(action: "register_failure", message: "aww")
   end

   it 'renders a registration success' do
      proto.register_success! "woo hoo"
      expect(output).to eq_json(action: "register_success", message: "woo hoo")
   end

   it 'renders a broadcast' do
      proto.broadcast! "SOME STUFF"
      expect(output).to eq_json(action: "broadcast", message: "SOME STUFF")
   end

   it 'renders talk from others' do
      proto.display_talk! "noober", "heya"
      expect(output).to eq_json(action: "talk", sender: "noober", message: "heya")
   end

   it 'renders a private message' do
      proto.display_private_message! "noober", "heya"
      expect(output).to eq_json(action: "pm", sender: "noober", message: "heya")
   end

   it "renders an area for display"

   it "renders a list of players to display" do
      proto.user_list! %w(noober fancypants joe)
      expect(output).to eq_json(action: "list", users: %w(noober fancypants joe))
   end

   it 'renders a notification about players leaving the area' do
      proto.player_leaves_area! "noober"
      expect(output).to eq_json(action: "player_leaves_area", username: "noober", direction: nil)
   end

   it 'renders a notification about players leaving the area in a certain direction' do
      proto.player_leaves_area! "noober", "north"
      expect(output).to eq_json(action: "player_leaves_area", username: "noober", direction: "north")
   end

   it 'renders a notification about players entering the area' do
      proto.player_enters_area! "noober"
      expect(output).to eq_json(action: "player_enters_area", username: "noober", direction: nil)
   end

   it 'renders a notification about players entering the area from a specific direction' do
      proto.player_enters_area! "noober", "north"
      expect(output).to eq_json(action: "player_enters_area", username: "noober", direction: "north")
   end

   it 'renders a user error' do
      proto.user_error! "oh noes!"
      expect(output).to eq_json(action: "user_error", message: "oh noes!")
   end

   it 'renders an undefined direction error' do
      proto.undefined_direction! "I don't know this direction"
      expect(output).to eq_json(action: "undefined_direction", message: "I don't know this direction")
   end
end