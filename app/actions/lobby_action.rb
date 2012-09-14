
class LobbyAction < Cramp::Websocket
   include GameWebSocketHandler
   include SessionSocketProtocol

   on_start :connected
   on_finish :disconnected

   def connected
      identify!
   end

   def disconnected

   end

private

   def session_created(session)
      @session = session

      # let the user know to use this session in future identifications
      set_session!(session)

      #TODO: if the user has not yet selected a game then ask them to select one
      #
      # (for now pick randomly)
      if session.game == nil
         session.game = Game.all.sample.slug
         session.save!
      end

      #TODO: have the user select a character

      # tell the user to reconnect at the appropriate game socket
      reconnect! "/games/#{session.game}"
   end

end