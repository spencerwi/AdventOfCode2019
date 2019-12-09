require "../day8"
require "spec"

describe Day8 do

  describe "#part1" do 
    it "behaves correctly for sample input" do
      example_inputs_and_outputs = {
      }
      example_inputs_and_outputs.each do|input, output|
        day8 = Day8.new(input)
        day8.part1.should eq output
      end
    end
  end

end