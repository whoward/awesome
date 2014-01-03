require 'handler'

class RegisterHandler < Handler

   def perform
      if !credentials.valid?
         conn.register_failure! "Please provide both a username and password"
      elsif user.valid?
         user.save!

         conn.register_success! "You have successfully registered! now logging you in."

         conn.session_created(session)
      else
         conn.register_failure! "Whoops! #{user.errors.full_messages.to_sentence}"
      end
   end

private
   hash_accessor :data, :username, :password

   class Credentials < Struct.new(:username, :password)
      def valid?
         username.present? && password.present?
      end
   end

   def credentials
      @credentials ||= Credentials.new(username, password) 
   end

   def user
      @user ||= User.new(login: username, password: password, password_confirmation: password)
   end

   def session
      @session ||= Session.generate!(user)
   end

end