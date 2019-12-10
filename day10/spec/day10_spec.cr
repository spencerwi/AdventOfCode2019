require "../day10"
require "spec"

describe Day10 do

  describe "#part1" do 
    it "behaves correctly for sample input" do
      example_inputs_and_outputs = {
        ".#..#\n.....\n#####\n....#\n...##" => 8
      }
      example_inputs_and_outputs.each do|input, output|
        day10 = Day10.new(input.lines)
        day10.part1.should eq output
      end
    end
  end

end
