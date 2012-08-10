#= require 'lib/jquery-1.7.2.min'
#= require 'lib/basic_object'
#= require 'core_extensions'
#= require 'game_screen'
#= require 'keyboard_input_handler'
#= require 'connection'
#= require 'input_parser'
#= require 'login_dialog'
#= require 'registration_dialog'

jQuery(document).ready ->
   GameScreen.instance
   Connection.instance
   KeyboardInputHandler.instance
   InputParser.instance
