require "../day5"
require "../IntcodeComputer"
require "spec"

describe IntcodeComputer do
  it "behaves correctly for sample input" do
    computer = IntcodeComputer.new([1002,4,3,4,33].map(&.to_i64), 1_i64)
    computer.run
    computer.output.should eq 1002_i64
    computer.program.should eq [1002,4,3,4,99].map(&.to_i64)
  end
end

# describe Day5 do

#   describe "#part1" do 
#     it "behaves correctly for sample input" do
#       example_inputs_and_outputs = {
#       }
#       example_inputs_and_outputs.each do|input, output|
#         day5 = Day5.new(input)
#         day5.part1.should eq output
#       end
#     end
#   end

# end
