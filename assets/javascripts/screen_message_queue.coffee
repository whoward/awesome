
class ScreenMessageQueue
   constructor: (root) ->
      @root = jQuery("<ul/>").attr("id", "messages").appendTo(root)

   append: (message, klass) ->
      jQuery("<li/>").addClass(klass).html(message.h()).appendTo(@root);

   classed: (klass, message) ->
      this.append "<span class='#{klass.h()}'>#{message.h()}</span>".safe()
      
   colored: (color, message) ->
      this.classed color, message