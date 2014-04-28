require 'spec_helper'
require 'awesome/game/world'

describe Awesome::Game::World do
   let(:world) {
      described_class.parse([
         {"id" => "1-01"},
         {"id" => "1-02"}
      ])
   }

   it_behaves_like "a world", described_class.new([])

   context '.parse' do
      it 'parses the raw data and assigns them to the returned world object' do
         expect(world).to be_a(Awesome::Game::World)
         expect(world.areas.length).to eq(2)
      end
   end

   context "#find_area_by_id" do
      it 'returns the matching area' do
         expect(world.find_area_by_id("1-01").id).to eq("1-01")
      end

      it 'returns nil for an undefined area' do
         expect(world.find_area_by_id("fake")).to eq(nil)
      end
   end
end