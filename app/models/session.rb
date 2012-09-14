
class Session
   MaxRefreshAttempts = 10
   TokenExpirationMinutes = 60

   include Mongoid::Document
   include Mongoid::Timestamps

   belongs_to :user
   belongs_to :character

   field :token, type: String
   field :token_expires_at, type: DateTime

   field :game, type: String

   validates :user, presence: true

   validates :token, presence: true,
                     uniqueness: true

   #TODO: validate character belongs to user

   def self.generate!(user)
      session = new(:user => user)
      session.refresh_token!
      session
   end

   def refresh_token!
      attempts = 0

      begin
         self.token = SecureRandom.hex(32)
         self.token_expires_at = TokenExpirationMinutes.from_now

         save!
      rescue Exception => e
         if attempts < MaxRefreshAttempts
            attempts += 1
            retry
         else
            raise e
         end
      end
   end

   def token_expired?
      self.token_expires_at < Time.now
   end
end