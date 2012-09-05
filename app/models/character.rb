require 'app/models/entity'

class Character < Entity

   field :name, type: String
   field :inventory, type: Hash
   
   belongs_to :user
end