require 'bcrypt'

class User
   include Mongoid::Document
   include Mongoid::Timestamps::Created

   scope :logged_in, where(logged_in: true)

   #TODO: remove me
   scope :in_instance, -> instance { logged_in.where(instance_id: instance.id) }
   scope :in_area,     -> area { where(area_id: area.id) }

   has_many :characters

   belongs_to :instance

   field :login, type: String
   field :hashed_password, type: String
   field :logged_in, type: Boolean, default: false
   field :area_id, type: String

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

   def login!
      update_attribute(:logged_in, true)
   end

   def logout!
      update_attribute(:logged_in, false)
   end

   def to_script_object
      Game::Scripting::Character.new(self)
   end

private
   def assign_password
      return if (password.blank? or password_confirmation.blank?) or password != password_confirmation
      
      self.hashed_password = BCrypt::Password.create(password)
   end

end