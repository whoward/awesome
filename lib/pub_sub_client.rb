require 'set'

class PubSubClient

   def initialize(user)
      @user = user
      @listeners = Hash.new

      @connected = false
   end

   #TODO: handle changing instances

   def connect!
      return if @connected

      log "connecting to redis"

      @pub = EM::Hiredis.connect("redis://localhost:6379")
      @sub = EM::Hiredis.connect("redis://localhost:6379")

      @sub.on(:message) do |channel, message|
         event = channel.split(".").last
         data = parse_json(message)

         log "rec: #{event.inspect} #{data.inspect}"
         
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

   def broadcast(message)
      instance_publish :broadcast, message: message
   end

   def chat(sender, message)
      instance_publish :chat, message: message, sender: sender
   end

   def private_message(recipient_id, sender, message)
      publish recipient_id, :pm, message: message, sender: sender
   end

   ## subscription methods

   def on_broadcast(&block)
      add_instance_listener :broadcast, &block
   end

   def on_chat(&block)
      add_instance_listener :chat, &block
   end

   def on_private_message(&block)
      add_user_listener :pm, &block
   end

private
   def parse_event_arguments(event, data)
      case event.to_sym
         when :broadcast then data.values_at(:message)
         when :chat then data.values_at(:sender, :message)
         when :pm then data.values_at(:sender, :message)
         else
            data
      end
   end

   def add_instance_listener(event, &block)
      add_listener @user.instance_id, event, &block
   end

   def add_user_listener(event, &block)
      add_listener @user.id, event, &block
   end

   def add_listener(id, event, &block)
      subscribe(id, event)

      (@listeners[event] ||= Set.new).add(block)
   end

   def remove_instance_listener(event, &block)
      remove_listener @user.instance_id, event, &block
   end

   def remove_user_listener(event, &block)
      remove_listener @user.id, event, &block
   end

   def remove_listener(id, event, &block)
      @listeners[event].try(:delete, block)

      unsubscribe(id, event) if @listeners[event].empty?
   end

   def notify_listeners(event, data)
      args = parse_event_arguments(event, data)

      log "notify: #{event.inspect} #{@listeners.keys.inspect} #{@listeners[event].inspect}"

      (@listeners[event] || []).each do |listener|
         listener.call(*args)
      end
   end

   def subscribe(id, event)
      scoped_event = "#{id}.#{event}"

      connect!

      log "sub: #{scoped_event.inspect}"

      @sub.subscribe(scoped_event)
   end

   def unsubscribe(id, event)
      scoped_event = "#{id}.#{event}"

      connect!

      log "unsub: #{scoped_event.inspect}"

      @sub.unsubscribe(scoped_event)
   end

   def user_publish(event, data={})
      publish @user.id, event, data
   end

   def instance_publish(event, data={})
      publish @user.instance_id, event, data
   end

   def publish(id, event, data={})
      connect!

      scoped_event = "#{id}.#{event}"

      log "pub: #{scoped_event.inspect} #{event.inspect} #{data.inspect}"

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