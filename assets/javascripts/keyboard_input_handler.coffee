
class window.KeyboardInputHandler
   constructor: ->
      jQuery(document).bind "keydown", (e) =>
         return if jQuery(e.target).is(":input")

         if e.keyCode is 8 or e.which is 8
            game_screen.input.backspace()
            return false         

         return true

      jQuery(document).bind "keypress", (e) =>
         return if jQuery(e.target).is(":input")

         char = String.fromCharCode(e.charCode)

         # check if the given character is a non printable character
         if /[\x00-\x1F]/.test(char)
            return this.command_key(e.keyCode || e.which)
         else
            return this.text_key(char)


   command_key: (keyCode) ->
      switch keyCode
         # enter key
         when 13 then game_screen.submit_input()

         # backspace key
         when 8 then game_screen.input.backspace()

         # meta keys
         when 91, 92, 93
            return true

         # function keys (use default behavior)
         when 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123
            return true

         # caps lock, scroll lock
         when 144, 145
            return true

         else return false
      
      return false

   text_key: (char) ->
      game_screen.input.append(char)
      return false
