
#
# This is my own personal base object class which I intend to use for CoffeeScript work
# to take advantage of accessors available in the server side (since I dont care about IE6)
# and whatever modern javascript paradigms I care about
#
class BasicObject
   # these base getters/setters were provided by ericdiscord from github here:
   #   https://github.com/jashkenas/coffee-script/issues/1039
   #
   # thank you very much!
   @get: (propertyName, func) ->
      Object.defineProperty @, propertyName,
         configurable: true
         enumerable: true
         get: func
   
   @set: (propertyName, func) ->
      Object.defineProperty @, propertyName,
         configurable: true
         enumerable: true
         set: func