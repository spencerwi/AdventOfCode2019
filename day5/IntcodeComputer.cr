enum ParameterMode
  Position,
  Immediate

  def self.parse(c : Char)
    case c
    when '0' then Position
    when '1' then Immediate
    else raise "Invalid ParameterMode: #{c}"
    end
  end
end

enum Opcode
  Add = 1,
  Multiply = 2,
  Assign = 3,
  Output = 4,
  Quit = 99
end

class IntcodeComputer
  @instruction_pointer : Int64 
  getter program

  def initialize(@program : Array(Int64), @program_input : Int64)
    @instruction_pointer = 0
  end

  # The "output"of an Intcode program is whatever's stored in memory location 0.
  def output : Int64
    @program[0]
  end

  def run : Int64
    loop do
      current_opcode, param_modes = parse_instruction(@program[@instruction_pointer])
      case current_opcode
      when Opcode::Quit then return output
      when Opcode::Add then 
        add(param_modes)
        @instruction_pointer += 4
      when Opcode::Multiply then 
        multiply(param_modes)
        @instruction_pointer += 4
      when Opcode::Assign then 
        assign
        @instruction_pointer += 2
      when Opcode::Output then 
        do_output(param_modes[0])
        @instruction_pointer += 2
      end
    end
    return output
  end

  private def parse_instruction(instruction : Int64) : Tuple(Opcode, Array(ParameterMode))
    opcode : Opcode = Opcode.new(instruction.to_i % 100)
    param_modes : Array(ParameterMode) = 
      case opcode
      when Opcode::Quit then
        [] of ParameterMode
      when Opcode::Add, Opcode::Multiply then
        [
          (instruction.to_i % 1_000) // 100,
          (instruction.to_i % 10_000) // 1_000,
          instruction.to_i // 10_000
        ].map {|it| ParameterMode.new(it)}
      when Opcode::Output, Opcode::Assign then
        [
          (instruction.to_i % 1_000) // 100
        ].map {|it| ParameterMode.new(it)}
      else raise "Invalid opcode: #{opcode}"
      end
    return {opcode, param_modes}
  end

  private def add(param_modes : Array(ParameterMode))
    binary_op(param_modes) {|a, b| a + b}
  end

  private def multiply(param_modes : Array(ParameterMode))
    binary_op(param_modes) {|a, b| a * b}
  end

  private def assign
    destination = @program[@instruction_pointer + 1]
    @program[destination] = @program_input
  end

  private def do_output(param_mode : ParameterMode)
    result = read_param(param_mode, 1)
    @program[0] = result
  end

  # Convenience method for operating on the values of two memory locations 
  # (yielding to a block) and storing the result in another memory location.
  private def binary_op(param_modes : Array(ParameterMode), &block : (Int64, Int64) -> Int64)
    operands = param_modes.first(2).map_with_index do |mode, idx| 
      read_param(mode, idx + 1)
    end

    result = (yield operands[0], operands[1])

    destination = @program[@instruction_pointer + 3]
    @program[destination] = result
  end

  # Convenience method for reading a parameter based on a given param mode
  private def read_param(param_mode : ParameterMode, param_number : Int32)
    case param_mode
    when ParameterMode::Position then
      location = @program[@instruction_pointer + param_number]
      return @program[location]
    when ParameterMode::Immediate then
      return @program[@instruction_pointer + param_number]
    else raise "Invalid ParameterMode: #{param_mode}"
    end
  end
end
