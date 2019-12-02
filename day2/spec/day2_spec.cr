require "../day2"
require "spec"

describe IntcodeComputer do
  it "can add correctly" do
    computer = IntcodeComputer.new([
      1,1,2,3, # Add 1 + 2 and store it in index 3
      99 # then halt
    ])
    computer.run
    computer.program[3].should eq 3
  end

  it "can multiply correctly" do
    computer = IntcodeComputer.new([
      2,1,2,3, # Multiply 1 * 2 and store it in index 3
      99 # then halt
    ])
    computer.run
    computer.program[3].should eq 2
  end

  it "works correctly for sample input" do
    computer = IntcodeComputer.new([
      1,9,10,3,2,3,11,0,99,30,40,50
    ])
    computer.run
    computer.output.should eq 3500
  end
end
