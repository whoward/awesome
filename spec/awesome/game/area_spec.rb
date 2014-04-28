require 'spec_helper'
require 'awesome/game/area'

describe Awesome::Game::Area do
   let(:world) { WorldDouble.instance }
   let(:data) { {"id" => "1-02", "name" => "Abandoned Shoppe", "description" => "ZOMG it's empty", "exits" => {"South" => "1-01"}} }

   let(:area) { described_class.new(world, data) }
   let(:empty_area) { described_class.new(world, {"id" => "1-01"}) }

   context "#initialize" do
      it 'assigns the attributes' do
         area = described_class.new(world, data)

         expect(area.id).to          eq("1-02")
         expect(area.name).to        eq("Abandoned Shoppe")
         expect(area.description).to eq("ZOMG it's empty")
         expect(area.exits).to       eq({"South" => "1-01"})
      end

      it 'raises an error if the id is missing' do
         expect(-> {
            described_class.new(world, {})
         }).to raise_error(Awesome::Game::Area::InvalidAreaError)
      end

      it 'assigns a default name if not given' do
         expect(empty_area.name).to eq("[untitled area]")
      end

      it 'assigns a default description if not given' do
         expect(empty_area.description).to eq("[missing description]")
      end

      it 'assigns a default hash of exits if not given' do
         expect(empty_area.exits).to eq({})
      end
   end

   context "#find_exit_name_by_id" do
      it 'returns the exit name for the given id' do
         expect(area.find_exit_name_by_id("1-01")).to eq("South")
      end

      it 'returns nil for an undefined exit' do
         expect(area.find_exit_name_by_id("1-03")).to eq(nil)
      end
   end

   context "#find_exit_id_by_name" do
      it 'returns the exit id for the given name' do
         expect(area.find_exit_id_by_name("South")).to eq("1-01")
      end
      it 'returns nil for an undefined exit' do
         expect(area.find_exit_id_by_name("North")).to eq(nil)
      end
   end

   context "#find_neighbour_by_name" do
      it 'returns the area identified by the given exit name' do
         expect(area.find_neighbour_by_name("South")).to eq(world.find_area_by_id("1-01"))
      end

      it 'returns nil if the neighbour is undefined' do
         expect(area.find_neighbour_by_name("North")).to eq(nil)
      end
   end

   context "#exits_with_names" do
      it 'returns a hash of exit names mapped to neighbour names' do
         expect(area.exits_with_names).to eq("South" => "Campfire")
      end

      it 'names undefined exits [unknown area]' do
         area = described_class.new(world, "id" => "1-02", "exits" => {"South" => "FAKE"})
         expect(area.exits_with_names).to eq("South" => "[unknown area]")
      end
   end

   context "#to_websocket_protocol" do
      it 'serializes the data' do
         expect(area.to_websocket_protocol).to eq({
            "name" => "Abandoned Shoppe",
            "description" => "ZOMG it's empty",
            "exits" => {
               "South" => "Campfire"
            }
         })
      end
   end

end