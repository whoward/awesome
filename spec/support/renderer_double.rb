
class RendererDouble

   def initialize(output)
      @output = output
   end

   def render(text)
      @output << text
   end

end