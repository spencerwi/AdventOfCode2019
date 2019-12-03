enum Opcode
  Add = 1,
  Multiply = 2,
  Quit = 99
end

class IntcodeComputer
  @program_counter : Int32 
  getter program

  def initialize(@program : Array(Int32))
    @program_counter = 0
  end

  def output
    @program[0]
  end

  def run
    loop do
      current_opcode = @program[@program_counter]
      case current_opcode
      when Opcode::Quit.value then return
      when Opcode::Add.value then add
      when Opcode::Multiply.value then multiply
      end
      @program_counter += 4
    end
  end

  private def add
    binary_op {|a, b| a + b}
  end

  private def multiply
    binary_op {|a, b| a * b}
  end

  # Convenience method for operating on the values of two memory locations (yielding to a block) and storing the result in another memory location
  private def binary_op(&block : (Int32, Int32) -> Int32)
    operands = [@program_counter + 1, @program_counter + 2]
      .map {|idx| @program[idx]}
      .map {|input_location| @program[input_location] }

    result = (yield operands[0], operands[1])

    storage_location = @program[@program_counter + 3]
    @program[storage_location] = result
  end
end

class Day2
  def initialize(@input : String)
  end

  def part1 : Int32
    run_with_noun_and_verb(12, 2)
  end

  def part2(goal : Int32) : Int32
    (0..99).each do |noun|
      (0..99).each do |verb|
        result = run_with_noun_and_verb(noun, verb)
        if result == goal
          return (100 * noun) + verb
        end
      end
    end
    raise "Something went wrong; we should've had an answer!"
  end

  private def run_with_noun_and_verb(noun : Int32, verb : Int32) : Int32
    computer = IntcodeComputer.new(@input.split(",").map(&.to_i))
    computer.program[1] = noun
    computer.program[2] = verb
    computer.run
    return computer.output
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day2 = Day2.new(File.read("input.txt"))
  puts "Part 1: #{day2.part1}"
  puts "Part 2: #{day2.part2(19690720)}"
end
