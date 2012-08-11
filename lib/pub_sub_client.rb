require 'set'

class PubSubClient

   def initialize(instance)
      @id = instance.id
      @subscriptions = Set.new
      @listeners = Hash.new

      @connected = false
   end

   #TODO: handle changing instances

   def connect!
      return if @connected

      @pub = EM::Hiredis.connect("redis://localhost:6379")
      @sub = EM::Hiredis.connect("redis://localhost:6379")

      @sub.on(:message) do |channel, message|
         event = channel.split(".").last
         data = parse_json(message)
         
         notify_listeners(event, data)
      end

      @connected = true
   end

   def disconnect!
      return unless @connected

      @pub.close_connection
      @sub.close_connection

      @connected = false
   end

   def broadcast(message)
      publish :broadcast, message: message
   end

   def chat(sender, message)
      publish :chat, message: message, sender: sender
   end

   # handles all of the on_xyz methods
   def respond_to?(method)
      !!(method =~ /^on_(\w+)$/) or super
   end

   def method_missing(method, *args, &block)
      if method.to_s =~ /^on_(\w+)$/
         return add_listener($1, &block)
      end
      super
   end

private
   def parse_event_arguments(event, data)
      case event.to_sym
         when :broadcast then data.values_at(:message)
         when :chat then data.values_at(:sender, :message)
         else
            data
      end
   end

   def add_listener(event, &block)
      subscribe(event)

      (@listeners[event] ||= Set.new).add(block)
   end

   def remove_listener(event, &block)
      @listeners[event].try(:delete, block)

      unsubscribe(event) if @listeners[event].empty?
   end

   def notify_listeners(event, data)
      args = parse_event_arguments(event, data)

      (@listeners[event] || []).each do |listener|
         listener.call(*args)
      end
   end

   def subscribe(event)
      return if @subscriptions.include?(event)

      @subscriptions.add(event)

      connect!

      @sub.subscribe("#{@id}.#{event}")
   end

   def unsubscribe(event)
      #TODO
   end

   def publish(event, data={})
      connect!

      @pub.publish("#{@id}.#{event}", encode_json(data))
   end

   def encode_json(obj)
      Yajl::Encoder.encode(obj)
   end
  
   def parse_json(str)
      Yajl::Parser.parse(str, :symbolize_keys => true) rescue {}
   end

end