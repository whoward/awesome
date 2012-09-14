
class Instance
   include Mongoid::Document
   include Mongoid::Timestamps

   has_many :users

   has_many :entities, dependent: :nullify

   def self.main_instance
      @main_instance ||= (Instance.first || Instance.create)
   end

end