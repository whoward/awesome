require 'socket_protocol'

module SessionSocketProtocol
   include SocketProtocol

private
   def identify!
      emit :identify # was formerly login_required
   end

   def set_session!(session)
      emit :session, token: session.token, username: session.user.login
   end

   def session_failure!(message)
      emit :session_failure, message: message
   end

   def login_failure!(message)
      emit :login_failure, message: message
   end

   def login_success!(message)
      emit :login_success, message: message
   end

   def register_failure!(message)
      emit :register_failure, message: message
   end

   def register_success!(message)
      emit :register_success, message: message
   end
end