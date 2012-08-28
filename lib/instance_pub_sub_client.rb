require 'pub_sub_client'

class InstancePubSubClient < PubSubClient

   attr_reader :instance_id

   def initialize(instance_id)
      super()
      @instance_id = instance_id
   end

   #TODO: handle changing instances as well

   ## publishing methods

   def broadcast(message)
      instance_publish :broadcast, message: message
   end

   def chat(sender, message)
      instance_publish :chat, message: message, sender: sender
   end

   ## subscription methods

   def on_broadcast(&block)
      add_instance_listener :broadcast, &block
   end

   def on_chat(&block)
      add_instance_listener :chat, &block
   end

protected
   def add_instance_listener(event, &block)
      add_listener :instance, instance_id, event, &block
   end

   def remove_instance_listener(event, &block)
      remove_listener :instance, instance_id, event, &block
   end

   def instance_publish(event, data={})
      publish :instance, instance_id, event, data
   end

   def parse_event_arguments(event, data)
      case event.to_sym
         when :broadcast then data.values_at(:message)
         when :chat then data.values_at(:sender, :message)
         else
            super
      end
   end
end