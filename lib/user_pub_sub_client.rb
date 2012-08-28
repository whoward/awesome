require 'instance_pub_sub_client'

class UserPubSubClient < InstancePubSubClient
   attr_reader :user_id, :area_id

   def initialize(user)
      super(user.instance_id)
      @user_id = user.id
   end

   def area=(area)
      # unsubscribe from the current area
      unsubscribe(:instance, instance_id, :area, @area_id, :travel) if @area_id

      @area_id = area.id

      subscribe :instance, instance_id, :area, @area_id, :travel
   end

   ## publishing methods

   def area_travel(user, from_area_id=nil, to_area_id=nil)
      # sometimes the area id's can match (both are nil or both are the same, like
      # what happens when a user is forcibly set to an area - example: when logging in)
      return if from_area_id == to_area_id

      data = {username: user, from_area_id: from_area_id, to_area_id: to_area_id}

      # publish an event for the exiting and entering area
      if from_area_id
         publish :instance, instance_id, :area, from_area_id, :travel, data
      end

      if to_area_id
         publish :instance, instance_id, :area, to_area_id, :travel, data
      end
   end

   ## subscription methods

   def on_private_message(&block)
      add_user_listener :pm, &block
   end

   def on_area_travel(&block)
      # since area is not constant we just register a general travel listener
      # and the area writer property will handle subscription/unsubscription
      (@listeners[:travel] ||= Set.new).add(block)
   end

protected

   def add_user_listener(event, &block)
      add_listener :user, user_id, event, &block
   end

   def remove_user_listener(event, &block)
      remove_listener :user, user_id, event, &block
   end

   def user_publish(event, data={})
      publish :user, user_id, event, data
   end

   def parse_event_arguments(event, data)
      case event.to_sym
         when :pm then data.values_at(:sender, :message)
         when :travel then data.values_at(:username, :from_area_id, :to_area_id)
         else
            super
      end
   end

end