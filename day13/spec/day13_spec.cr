require "../day13"
require "spec"

describe Day13 do

  describe "#part1" do 
    it "behaves correctly for sample input" do
      example_inputs_and_outputs = {
      }
      example_inputs_and_outputs.each do|input, output|
        day13 = Day13.new(input)
        day13.part1.should eq output
      end
    end
  end

end