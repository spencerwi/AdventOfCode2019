require "../day9"
require "spec"

describe IntcodeComputer do

  it "behaves correctly for sample input" do
    # This program should spit out th value in the middle
    computer = IntcodeComputer.new(
      [104_i64,1125899906842624_i64,99_i64],
      [1_i64]
    )
    computer.run.should eq 1125899906842624_i64

    # This program should spit out a 16-digit number
    computer = IntcodeComputer.new(
      [1102_i64,34915192_i64,34915192_i64,7_i64,4_i64,7_i64,99_i64,0_i64],
      [1_i64]
    )
    computer.run.to_s.chars.size.should eq 16
  end
end
