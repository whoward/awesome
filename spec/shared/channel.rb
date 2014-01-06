
shared_examples "a channel" do |object|

   it 'can connect' do
      expect(object).to respond_to(:connect)
   end

   it 'can connect, raising errors if it is already connected' do
      expect(object).to respond_to(:connect!)
   end

   it 'can check to see if it is connected' do
      expect(object).to respond_to(:connected?)
   end

   it 'can disconnect' do
      expect(object).to respond_to(:disconnect)
   end

   it 'can disconnect, raising errors if it is already disconnected' do
      expect(object).to respond_to(:disconnect!)
   end

   it 'can publish messages' do
      expect(object).to respond_to(:publish)
   end

   it 'can subscribe to events' do
      expect(object).to respond_to(:subscribe)
   end

   it 'can unsubscribe from events' do
      expect(object).to respond_to(:unsubscribe)
   end

end