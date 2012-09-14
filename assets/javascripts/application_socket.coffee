#= require lib/reconnecting-websocket.min

class ApplicationSocket

   constructor: (path) ->
      @listeners = []
      @queue = []

      @reconnect(path)

   addListener: (listener) ->
      @listeners.push(listener) unless @listeners.indexOf(listener) >= 0

   removeListener: (listener) ->
      idx = @listeners.indexOf(listener)

      if idx >= 0
         @listeners.splice(idx, 1)

   send: (message) ->
      if @socket.readyState is WebSocket.OPEN
         @socket.send(JSON.stringify(message))
      else
         @queue.push(message)

   reconnect: (path) ->
      # perform garbage collection of any existing socket
      if @socket
         @socket.onopen = null
         @socket.onerror = null
         @socket.onclose = null
         @socket.onmessage = null

         #TODO: maybe this should go before we null out the callbacks? not sure 
         # what the user experience will be
         @socket.close()

      # create a new socket 
      @socket = new ReconnectingWebSocket("ws://#{window.location.host}#{path}")

      # assign callbacks to the web socket methods
      @socket.onopen    = ((ev)=> @socketOpened(ev)   )
      @socket.onerror   = ((ev)=> @socketErrored(ev)  )
      @socket.onclose   = ((ev)=> @socketClosed(ev)   )
      @socket.onmessage = ((ev)=> @socketMessaged(ev) )

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