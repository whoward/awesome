require 'handler'

class LoginHandler < Handler

   def perform
      if !credentials.valid?
         conn.login_failure! "Please provide both a username and a password"
      elsif user == nil
         conn.login_failure! "Login error: no matching credentials for the username/password you provided"
      elsif user.logged_in
         conn.login_failure! "That account is already in use (perhaps a bad thing?)"
      else
         conn.login_success! "You have successfully logged in, welcome!"

         conn.session_created session
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
      @user ||= User.find_by_credentials(login: username, password: password)
   end

   def session
      @session ||= Session.generate!(user)
   end

end