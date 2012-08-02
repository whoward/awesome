#= require lib/reconnecting-websocket.min

class ApplicationSocket

   constructor: (@path, @domain=window.location.host) ->
      @listeners = []
      @queue = []

      @socket = new ReconnectingWebSocket("ws://#{@domain}#{@path}")

      @socket.onopen    = ((ev)=> @socketOpened(ev)   )
      @socket.onerror   = ((ev)=> @socketErrored(ev)  )
      @socket.onclose   = ((ev)=> @socketClosed(ev)   )
      @socket.onmessage = ((ev)=> @socketMessaged(ev) )

   addListener: (listener) ->
      @listeners.push(listener)
      #TODO: only add if not already added

   removeListener: (listener) ->
      #TODO: write me

   send: (message) ->
      if @socket.readyState is WebSocket.OPEN
         @socket.send(JSON.stringify(message))
      else
         @queue.push(message)

# private -------------
   socketOpened: (ev) ->
      @send(msg) for msg in @queue

      @queue = []

      @notify "socketOpened", ev

   socketClosed: (ev) ->
      @notify "socketClosed", ev

   socketErrored: (ev) ->
      @notify "socketErrored", ev

   socketMessaged: (ev) ->
      message = JSON.parse(ev.data)

      @notify "socketMessage", message

   notify: (methodName, args...) ->
      args.unshift(this)

      for listener in @listeners
         if "function" is typeof(listener[methodName])
            listener[methodName].apply(listener, args)