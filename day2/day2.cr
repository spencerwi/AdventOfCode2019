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

  pivate def add
    binary_op {|a, b| a + b}
  end

  private def multiply
    binary_op {|a, b| a * b}
  end

  private def binary_op(&block : (Int32, Int32) -> Int32)
    inputs = [@program_counter + 1, @program_counter + 2]
      .map {|idx| @program[idx]}
      .map {|input_location| @program[input_location] }
    result = yield inputs[0], inputs[1]
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
    noun = 0
    while noun <= 99 
      verb = 0
      while verb <= 99 
        result = run_with_noun_and_verb(noun, verb)
        if result == goal
          return (100 * noun) + verb
        end
        verb += 1
      end
      noun += 1
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
