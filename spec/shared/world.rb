
shared_examples "a world" do |object|

   it 'can access a list of all areas' do
      expect(object).to respond_to(:areas)
      expect(object.areas).to be_a(Array)
   end

   it "can access an area by it's id" do
      expect(object).to respond_to(:find_area_by_id)
   end

end