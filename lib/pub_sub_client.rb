require 'set'

class PubSubClient

   def initialize(user)
      @user = user
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

   def area=(area)
      # unsubscribe from the current area
      unsubscribe(:area, @area_id, :travel) if @area_id

      @area_id = area.id

      subscribe :area, @area_id, :travel
   end

   ## publishing methods

   def broadcast(message)
      instance_publish :broadcast, message: message
   end

   def chat(sender, message)
      instance_publish :chat, message: message, sender: sender
   end

   def private_message(recipient_id, sender, message)
      publish :user, recipient_id, :pm, message: message, sender: sender
   end

   def area_travel(user, from_area_id=nil, to_area_id=nil)
      # sometimes the area id's can match (both are nil or both are the same, like
      # what happens when a user is forcibly set to an area - example: when logging in)
      return if from_area_id == to_area_id
      
      # publish an event for the exiting and entering area
      if from_area_id
         publish :area, from_area_id, :travel, username: user, from_area_id: from_area_id, to_area_id: to_area_id
      end

      if to_area_id
         publish :area, to_area_id, :travel, username: user, from_area_id: from_area_id, to_area_id: to_area_id
      end
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

   def on_area_travel(&block)
      # since area is not constant we just register a general travel listener
      # and the area writer property will handle subscription/unsubscription
      (@listeners[:travel] ||= Set.new).add(block)
   end

private
   def parse_event_arguments(event, data)
      case event.to_sym
         when :broadcast then data.values_at(:message)
         when :chat then data.values_at(:sender, :message)
         when :pm then data.values_at(:sender, :message)
         when :travel then data.values_at(:username, :from_area_id, :to_area_id)
         else
            data
      end
   end

   def add_instance_listener(event, &block)
      add_listener :instance, @user.instance_id, event, &block
   end

   def add_user_listener(event, &block)
      add_listener :user, @user.id, event, &block
   end

   def add_listener(type, id, event, &block)
      subscribe(type, id, event)

      (@listeners[event] ||= Set.new).add(block)
   end

   def remove_instance_listener(event, &block)
      remove_listener :instance, @user.instance_id, event, &block
   end

   def remove_user_listener(event, &block)
      remove_listener :user, @user.id, event, &block
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

   def subscribe(type, id, event)
      scoped_event = "#{type}.#{id}.#{event}"

      connect!

      log "sub: #{scoped_event.inspect}"

      @sub.subscribe(scoped_event)
   end

   def unsubscribe(type, id, event)
      scoped_event = "#{type}.#{id}.#{event}"

      connect!

      log "unsub: #{scoped_event.inspect}"

      @sub.unsubscribe(scoped_event)
   end

   def user_publish(event, data={})
      publish :user, @user.id, event, data
   end

   def instance_publish(event, data={})
      publish :instance, @user.instance_id, event, data
   end

   def publish(type, id, event, data={})
      connect!

      scoped_event = "#{type}.#{id}.#{event}"

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