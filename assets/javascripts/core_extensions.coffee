
Array::contains = (x) ->
   this.indexOf(x) >= 0

Array::compact = (x) ->
   result = []
   for elem in this
      result.push(elem) unless elem is null or typeof elem is "undefined"
   result

String::safe = ->
   @__is_html_safe = true
   this

String::html_escape = ->
   if @__is_html_safe
      this
   else
      escaped = new String(this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'))
      escaped.__is_html_safe = true
      escaped

String::h = ->
   this.html_escape().toString()