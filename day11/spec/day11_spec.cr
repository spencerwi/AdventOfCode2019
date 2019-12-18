require "../day11"
require "spec"

describe Day11 do

  describe "#part1" do 
    it "behaves correctly for sample input" do
      example_inputs_and_outputs = {
      }
      example_inputs_and_outputs.each do|input, output|
        day11 = Day11.new(input)
        day11.part1.should eq output
      end
    end
  end

end