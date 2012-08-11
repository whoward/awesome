require 'bcrypt'

class User
   include Mongoid::Document
   include Mongoid::Timestamps

   field :login, type: String
   field :hashed_password, type: String
   field :area_id, type: String

   belongs_to :instance

   before_validation :assign_password

   validates :login, uniqueness: true,
                     presence: true

   validates :hashed_password, presence: true

   attr_accessor :password, :password_confirmation

   def self.find_by_credentials(credentials={})
      user = User.where(login: credentials[:login]).first

      return nil if user == nil

      if BCrypt::Password.new(user.hashed_password) == credentials[:password]
         return user
      else
         return nil
      end
   end

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

private
   def assign_password
      return if (password.blank? or password_confirmation.blank?) or password != password_confirmation
      
      self.hashed_password = BCrypt::Password.create(password)
   end

end