require 'set'

class PubSubClient

   def initialize
      @listeners = Hash.new
      @connected = false
   end

   def connect!
      return if @connected

      log "connecting to redis"

      @pub = EM::Hiredis.connect("redis://localhost:6379")
      @sub = EM::Hiredis.connect("redis://localhost:6379")

      @sub.on(:message) do |channel, message|
         event = channel.split(".").last
         data = parse_json(message)

         log "#{channel}: #{data.inspect}"
         
         notify_listeners(event.to_sym, data)
      end

      @connected = true
   end

   def disconnect!
      return unless @connected

      @pub.close_connection
      @sub.close_connection

      @connected = false
   end

   ## publishing methods

   def private_message(recipient_id, sender, message)
      publish :user, recipient_id, :pm, message: message, sender: sender
   end


protected

   def parse_event_arguments(event, data)
      []
   end

private
   
   def add_listener(type, id, event, &block)
      subscribe(type, id, event)

      (@listeners[event] ||= Set.new).add(block)
   end

   def remove_listener(type, id, event, &block)
      @listeners[event].try(:delete, block)

      unsubscribe(type, id, event) if @listeners[event].empty?
   end

   def notify_listeners(event, data)
      args = parse_event_arguments(event, data)

      (@listeners[event] || []).each do |listener|
         listener.call(*args)
      end
   end

   def subscribe(*keys)
      raise ArgumentError.new("must have at least 1 key") if keys.length <= 1

      scoped_event = keys.join(".")

      connect!

      log "sub: #{scoped_event.inspect}"

      @sub.subscribe(scoped_event)
   end

   def unsubscribe(*keys)
      raise ArgumentError.new("must have at least 1 key") if keys.length <= 1

      scoped_event = keys.join(".")

      connect!

      log "unsub: #{scoped_event.inspect}"

      @sub.unsubscribe(scoped_event)
   end

   def publish(*keys, data)
      raise ArgumentError.new("must have at least 1 key") if keys.length <= 1

      scoped_event = keys.join(".")

      connect!

      log "pub: #{scoped_event.inspect} #{data.inspect}"

      @pub.publish(scoped_event, encode_json(data))
   end

   def encode_json(obj)
      Yajl::Encoder.encode(obj)
   end
  
   def parse_json(str)
      Yajl::Parser.parse(str, :symbolize_keys => true) rescue {}
   end

   def log(message)
      Awesome::App.log(message)
   end

end