
class ScreenInput
   constructor: (root) ->
      @root = jQuery("<div/>").attr("id", "console").appendTo(root)

      @text = ""
   
   clear: ->
      this.set ""

   get: ->
      @text
   
   set: (text) ->
      @text = text
      @root.html "> #{@text}_"

   append: (chars) ->
      this.set @text + chars

   backspace: ->
      this.set @text[0..-2]