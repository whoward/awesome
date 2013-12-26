#= require 'lib/jqmodal.r14'

class LoginDialog extends BasicObject
   constructor: (root) ->
      @root = jQuery("<div/>").attr("id", "login").appendTo(root)

      jQuery("<label/>").html("Login").appendTo(@root)
      @username = jQuery("<input type='text'/>").appendTo(@root)

      jQuery("<label/>").html("Password").appendTo(@root)
      @password = jQuery("<input type='password'/>").appendTo(@root)

      @login = jQuery("<button/>").html("Log In").appendTo(@root)

      @register = jQuery("<a href='#'/>").html("Register").appendTo(@root)

      # @root.jqm(modal: true)

      jQuery(window).bind("resize", => 
         left = jQuery(window).width() / 2 - jQuery(@root).width() / 2
         top = jQuery(window).height() / 2 - jQuery(@root).height() / 2

         @root.css({left: left, top: top})
      ).trigger("resize")

      @login.click =>
         this.submit()

      @register.click =>
         this.show_registration_dialog()

      @username.add(@password).keypress (ev) =>
         if (ev.which || ev.keyCode) is 13
            this.submit()

   @get "instance", ->
      @__instance ||= new LoginDialog("body")

   show: ->
      #@root.jqmShow()
      @root.show()
      @username.focus()

   hide: ->
      #@root.jqmHide()
      @root.hide()

   submit: ->
      Connection.instance.login(@username.val(), @password.val())
      @username.val(null)
      @password.val(null)

   show_registration_dialog: ->
      @hide()
      RegistrationDialog.instance.show()