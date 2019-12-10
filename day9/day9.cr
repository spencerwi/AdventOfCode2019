require "./IntcodeComputer"

class Day9
  def initialize(@program : Array(Int64))
  end

  def part1
    computer = IntcodeComputer.new(@program, [1_i64])
    computer.run
  end

  def part2
    computer = IntcodeComputer.new(@program, [2_i64])
    computer.run
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day9 = Day9.new(File.read("input.txt").split(",").map(&.to_i64))
  puts "Part 1: #{day9.part1}"
  puts "Part 2: #{day9.part2}"
end
