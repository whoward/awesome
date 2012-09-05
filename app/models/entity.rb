
class Entity
   include Mongoid::Document

   scope :in_instance, -> instance { logged_in.where(instance_id: instance.id) }
   scope :in_area,     -> area { where(area_id: area.id) }

   field :area_id, type: String
   field :attrs, type: Hash

   belongs_to :instance

   def area(world=World.instance)
      world.find_area_by_id(self.area_id)
   end

   def area=(id_or_area)
      if id_or_area.is_a? String
         self.area_id = id_or_area
      else
         self.area_id = id_or_area.id
      end
   end

end