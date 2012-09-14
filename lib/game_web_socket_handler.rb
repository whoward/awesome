
# this module handles all data parsing and dispatching of actions received from
# the client.  it is also responsible for handling authentication requests and
# refreshing the session token.
module GameWebSocketHandler

   #TODO: at about 80% of it's lifetime, refresh and send the user a new session token

   def self.included(base)
      base.send(:on_data, :data_received)
   end

   def data_received(data)
      msg = parse_json(data) #TODO: rescue malformed data

      handler_method = "handle_#{msg[:action]}"

      #TODO: use a state machine for session, if not validated then do not allow
      # any action.

      if respond_to?(handler_method, false)
         send(handler_method, msg)
      else
         puts "unhandled message action: #{msg[:action].inspect}"
      end
   end

   def handle_session(data)
      token = data[:token]

      protocol_error! "missing parameter: token" if token.blank?

      session = Session.where(token: token).first

      if session.try(:expired?)
         session_failure! "session has expired"
      elsif session
         session_created(session)
      else
         session_failure! "invalid session"
      end
   end

   def handle_login(data)
      username = data[:username]
      password = data[:password]

      if username.blank? or password.blank?
         return login_failure! "Please provide both a username and password"
      end

      user = User.find_by_credentials login: username, password: password

      if user == nil
         return login_failure!("Login error: no matching credentials for the username/password you provided")
      end

      if user.logged_in
         login_failure! "That account is already in use (perhaps a bad thing?)"
      else
         login_success! "You have successfully logged in, welcome!"

         session_created Session.generate!(user)
      end
   end

   def handle_register(data)
      username = data[:username]
      password = data[:password]

      if username.blank? or password.blank?
         return register_failure! "Please provide both a username and password"
      end

      user = User.new(login: username, password: password, password_confirmation: password)

      if user.valid?
         user.save!

         register_success! "You have successfully registered! now logging you in."

         session_created Session.generate!(user)
      else
         register_failure! "Whoops! #{user.errors.full_messages.to_sentence}"
      end
   end
end