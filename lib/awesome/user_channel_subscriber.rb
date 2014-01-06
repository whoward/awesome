require 'awesome/channel_subscriber'

module Awesome
   class UserChannelSubscriber < ChannelSubscriber

      attr_reader :user
      
      def initialize(user, *args)
         super(*args)
         @user = user
      end

      def user=(rhs)
         subscribed_events.each do |ev|
            resubscribe ev, ev.gsub("user.#{user.id}", "user.#{rhs.id}")
         end

         @user = rhs
      end

      def listen(*keys, &block)
         super(:user, user.id, *keys, &block)
      end

      def unlisten(*keys, &block)
         super(:user, user.id, *keys, &block)
      end
   end
end