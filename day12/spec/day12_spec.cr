require "../day12"
require "spec"

describe Day12 do

  describe "#part1" do 
    it "behaves correctly for sample input" do
      example_inputs_and_outputs = {
      }
      example_inputs_and_outputs.each do|input, output|
        day12 = Day12.new(input)
        day12.part1.should eq output
      end
    end
  end

end