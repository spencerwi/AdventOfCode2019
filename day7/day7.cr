require "./IntcodeComputer"

class Day7
  @input_program : Array(Int64)

  def initialize(input_program : Array(Int64))
    @input_program = input_program.clone # make sure we're not modifying the "master copy" of the program.
  end

  # Problem statement: find the largest output value from a computer, based on 
  # a set of input settings to a series of amplifiers. 
  def part1
    (0_i64..4_i64).to_a.permutations(5).max_of do |amplifier_settings|
      previous_amp_result = 0_i64
      ('A'..'E').each_with_index do |amp, idx|
        # array.pop in Crystal pops from the right, so we put our "input queue" in what would appear to be reverse order.
        input_queue = [previous_amp_result, amplifier_settings[idx.to_i64]]
        computer = IntcodeComputer.new(@input_program, input_queue)
        previous_amp_result = computer.run
      end
      previous_amp_result
    end
  end

  # Problem statement: use networked amplifiers (A's output goes to B, B's output
  # goes to C, etc) in a loop (so E -> A), and test permutations of digits 
  # between 5 and 9 (inclusive), to find the largest possible output from E.
  def part2
    (5_i64..9_i64).to_a.permutations(5).max_of do |amplifier_settings|
      # Create all our amp computers
      computers_by_name = ('A'..'E').to_h do |name|
        computer = NetworkedIntcodeComputer.new(name, @input_program)
        {name, computer}
      end

      # Then chain together their input channels and feed in the initial inputs
      computers_by_name.each do |name, computer| 
        if name == 'E'
          computer.output_channel = (computers_by_name['A']).input_channel
        else
          computer.output_channel = computers_by_name[name + 1].input_channel # 'A' + 1 == 'B'
        end


        amplifier_input_idx = ('A'..'E').index(name).not_nil!

        # Sending initial inputs must be done async, otherwise the main thread will block.
        spawn do
          computer.input_channel.send(amplifier_settings[amplifier_input_idx])
        end
      end

      #computers_by_name.each_value do |amp|
      #  puts "#{amp.name}, in: #{amp.input_channel}, out: #{amp.output_channel}"
      #end

      # Kick them all off concurrently for their first round
      computers_by_name.each_value do |amp|
        amp.run
      end

      # Block the main thread until the first round finishes 
      Fiber.yield

      # Amplifier A gets 0 as its next input
      spawn do
        computers_by_name['A'].input_channel.send(0_i64)
      end

      # Block the main thread until _that_ finishes
      Fiber.yield

      # Now just run them all until one halts
      until computers_by_name.values.any?(&.has_finished)
        Fiber.yield
      end

      computers_by_name['E'].most_recent_output.not_nil!
    end
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day7 = Day7.new(File.read("input.txt").split(",").map(&.to_i64))
  puts "Part 1: #{day7.part1}"
  puts "Part 2: #{day7.part2}"
end
