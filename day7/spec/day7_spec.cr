require "../day7"
require "spec"

describe Day7 do

  describe "#part1" do 
    it "behaves correctly for sample input" do
      example_inputs_and_outputs = {
      }
      example_inputs_and_outputs.each do|input, output|
        day7 = Day7.new(input)
        day7.part1.should eq output
      end
    end
  end

end