require 'handler'

class SessionHandler < Handler

   def perform
      if token.blank?
         conn.protocol_error! "missing parameter: token"
      elsif session == nil
         conn.session_failure! "invalid session"
      elsif session.expired?
         conn.session_failure! "session has expired"
      else
         conn.session_created(session)
      end
   end

private
   hash_accessor :data, :token

   def session
      @session ||= Session.where(token: token).first
   end

end