require "../day3"
require "spec"

describe Day3 do

    describe "#part1" do 
        it "behaves correctly for sample input" do
          example_inputs_and_outputs = {
            "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83" => 159,
            "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7" => 135
          }
          example_inputs_and_outputs.each do|input, output|
            day3 = Day3.new(input.lines)
            day3.part1.should eq output
          end
        end
    end

    describe "#part2" do 
        it "behaves correctly for sample input" do
          example_inputs_and_outputs = {
            "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83" => 610,
            "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7" => 410
          }
          example_inputs_and_outputs.each do|input, output|
            day3 = Day3.new(input.lines)
            day3.part2.should eq output
          end
        end
    end
end
