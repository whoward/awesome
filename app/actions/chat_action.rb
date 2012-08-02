require 'yajl'
require 'em-hiredis'

class ChatAction < Cramp::Websocket
  on_start :connected
  on_finish :disconnected
  on_data :data_received
  
  def connected
    @pub = EM::Hiredis.connect("redis://localhost:6379")
    @sub = EM::Hiredis.connect("redis://localhost:6379")
  end
  
  def disconnected
    publish :action => 'control', :user => @user, :message => 'left the chat room'

    @pub.close_connection
    @sub.close_connection
  end
  
  def data_received(data)
    msg = parse_json(data)

    return unless respond_to?("handle_#{msg[:action]}", false)

    send("handle_#{msg[:action]}", msg)
  end
  
  def handle_join(msg)
    @user = msg[:user]
    subscribe
    publish :action => 'control', :user => @user, :message => 'joined the chat room'
  end
  
  def handle_message(msg)
    publish msg.merge(:user => @user)
  end
  
private

  def subscribe
    @sub.subscribe('chat')
    @sub.on(:message) {|channel, message| render(message) }    
  end
  
  def publish(message)
    @pub.publish('chat', encode_json(message))
  end
  
  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
  
  def parse_json(str)
    Yajl::Parser.parse(str, :symbolize_keys => true) rescue {}
  end
end