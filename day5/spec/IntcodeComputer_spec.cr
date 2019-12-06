require "./spec_helper"
require "spectator"

def example_conditional_jump_test_cases
  [
    {"3,9,8,9,10,9,4,9,99,-1,8", 8, 1},
    {"3,9,8,9,10,9,4,9,99,-1,8", 7, 0},
    {"3,9,7,9,10,9,4,9,99,-1,8", 5, 1},
    {"3,9,7,9,10,9,4,9,99,-1,8", 9, 0},
    {"3,3,1108,-1,8,3,4,3,99", 8, 1},
    {"3,3,1108,-1,8,3,4,3,99", 7, 0},
    {"3,3,1107,-1,8,3,4,3,99", 5, 1},
    {"3,3,1107,-1,8,3,4,3,99", 9, 0},
    {"3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", 1, 1},
    {"3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", 0, 0},
    {"3,3,1105,-1,9,1101,0,0,12,4,12,99,1", 1, 1},
    {"3,3,1105,-1,9,1101,0,0,12,4,12,99,1", 0, 0}
  ]
end

Spectator.describe IntcodeComputer do
  sample example_conditional_jump_test_cases do |test_case|
    it "should pass conditional-jump tests" do
      program_str, input, expected_output = test_case
      program = program_str.split(",").map(&.to_i64)
      computer = IntcodeComputer.new(program, input.to_i64)
      expect(computer.run).to eq expected_output.to_i64
    end
  end

  it "behaves correctly for complex sample case" do
    program = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99].map(&.to_i64)
    computer = IntcodeComputer.new(program, 7)
    expect(computer.run).to eq 999_i64
    computer = IntcodeComputer.new(program, 8)
    expect(computer.run).to eq 1000_i64
    computer = IntcodeComputer.new(program, 9)
    expect(computer.run).to eq 1001_i64
  end
end