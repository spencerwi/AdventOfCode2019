require "./IntcodeComputer"

class Day5
  def initialize(@program : Array(Int64))
  end

  def part1
    computer = IntcodeComputer.new(@program, 1)
    computer.run
  end

  def part2
    computer = IntcodeComputer.new(@program, 5)
    computer.run
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day5 = Day5.new(File.read("input.txt").split(",").map(&.to_i64))
  puts "Part 1: #{day5.part1}"
  puts "Part 2: #{day5.part2}"
end
