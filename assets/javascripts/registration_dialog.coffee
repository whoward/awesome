#= require 'lib/jqmodal.r14'

class window.RegistrationDialog
   constructor: (root) ->
      @root = jQuery("<div/>").attr("id", "register").appendTo(root)

      jQuery("<label/>").html("Login").appendTo(@root)
      @username = jQuery("<input type='text'/>").appendTo(@root)

      jQuery("<label/>").html("Password").appendTo(@root)
      @password = jQuery("<input type='password'/>").appendTo(@root)

      @register = jQuery("<button/>").html("Register").appendTo(@root)

      @root.jqm({modal: true})

      jQuery(window).bind("resize", => 
         left = jQuery(window).width() / 2 - jQuery(@root).width() / 2
         top = jQuery(window).height() / 2 - jQuery(@root).height() / 2

         @root.css({left: left, top: top})
      ).trigger("resize")

      @register.click =>
         connection.register(@username.val(), @password.val())
         @username.val(null)
         @password.val(null)

   show: ->
      @root.jqmShow()
      @username.focus()

   hide: ->
      @root.jqmHide()