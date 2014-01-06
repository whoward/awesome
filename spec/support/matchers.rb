require 'json'

RSpec::Matchers.define :eq_json do |expected|
   match do |actual|
      JSON.parse(actual, symbolize_names: true) == expected
   end
end

describe 'custom matchers' do
   context 'eq_json' do
      it 'equals a string with the same value' do
         expect('{"foo":123}').to eq_json(foo: 123)
      end

      it "doesn't equal a string with a different value" do
         expect('{"foo":123}').not_to eq_json(foo: 456)
      end
   end
end