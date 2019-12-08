require "./IntcodeComputer"

class Day7
  @input_program : Array(Int64)

  def initialize(input_program : Array(Int64))
    @input_program = input_program.clone # make sure we're not modifying the "master copy" of the program.
  end

  # Problem statement: find the largest output value from a computer, based on 
  # a set of input settings to a series of amplifiers. 
  def part1
    [0_i64,1_i64,2_i64,3_i64,4_i64].permutations(5).max_of do |amplifier_settings|
      previous_amp_result = 0_i64
      ('A'..'E').each_with_index do |amp, idx|
        # array.pop in Crystal pops from the right, so we put our "input queue" in what would appear to be reverse order.
        input_queue = [previous_amp_result, amplifier_settings[idx.to_i64]]
        computer = IntcodeComputer.new(@input_program.clone, input_queue)
        previous_amp_result = computer.run
      end
      previous_amp_result
    end
  end

  def part2
    # TODO: this!
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day7 = Day7.new(File.read("input.txt").split(",").map(&.to_i64))
  puts "Part 1: #{day7.part1}"
  #puts "Part 2: #{day7.part2}"
end
