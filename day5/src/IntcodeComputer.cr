DEBUG = false
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
  Input = 3,
  Output = 4,
  JumpIfTrue = 5,
  JumpIfFalse = 6,
  LessThan = 7,
  EqualTo = 8,
  Quit = 99
end

class IntcodeComputer
  @instruction_pointer : Int64 
  @printed_values : Array(Int64)
  getter program

  def initialize(@program : Array(Int64), @program_input : Int64)
    @instruction_pointer = 0
    @printed_values = [] of Int64
  end

  def run : Int64
    loop do
      instruction = @program[@instruction_pointer]
      current_opcode, param_modes = parse_instruction(instruction)
      next_jump_amount = 0
      if DEBUG
      puts "Excuting #{instruction} (#{current_opcode}, #{param_modes})"
      end 
      case current_opcode
      when Opcode::Quit then return @printed_values.last
      when Opcode::Add then 
        add(param_modes)
        next_jump_amount = 4
      when Opcode::Multiply then 
        multiply(param_modes)
        next_jump_amount = 4
      when Opcode::Input then 
        do_input()
        next_jump_amount = 2
      when Opcode::Output then 
        do_output(param_modes[0])
        next_jump_amount = 2
      when Opcode::JumpIfTrue
        already_jumped = jump_if_true(param_modes)
        next_jump_amount = 3 unless already_jumped
      when Opcode::JumpIfFalse
        already_jumped = jump_if_false(param_modes)
        next_jump_amount = 3 unless already_jumped
      when Opcode::LessThan
        less_than(param_modes)
        next_jump_amount = 4
      when Opcode::EqualTo
        equal_to(param_modes)
        next_jump_amount = 4
      end
      @instruction_pointer += next_jump_amount
      if DEBUG
      puts "IP: #{@instruction_pointer}, Program: #{@program}"
      end
    end
    return @printed_values.last
  end

  private def parse_instruction(instruction : Int64) : Tuple(Opcode, Array(ParameterMode))
    digits = instruction.to_s.rjust(5, '0').chars
    puts digits
    opcode : Opcode = Opcode.new(digits.last(2).join("").to_i)
    param_modes : Array(ParameterMode) = 
      case opcode
      when Opcode::Quit then
        [] of ParameterMode
      when Opcode::Input, Opcode::Output then
        [ParameterMode.parse(digits[2])]
      when Opcode::JumpIfFalse, Opcode::JumpIfTrue then
        digits[1..2].reverse.map{|it| ParameterMode.parse(it)}
      else
        digits.first(3).reverse.map{|it| ParameterMode.parse(it)}
      end
    puts [opcode, param_modes]
    return {opcode, param_modes}
  end

  private def add(param_modes : Array(ParameterMode))
    binary_op(param_modes) {|a, b| a + b}
  end

  private def multiply(param_modes : Array(ParameterMode))
    binary_op(param_modes) {|a, b| a * b}
  end

  private def do_input
    write_result(1, @program_input)
  end

  private def do_output(param_mode : ParameterMode)
    result = read_param(param_mode, 1)
    @printed_values << result
    puts result
  end

  # Returns a Bool indicating whether a jump happened
  private def jump_if_true(param_modes : Array(ParameterMode)) : Bool
    jump_if(param_modes) {|a, _| !(a.zero?) }
  end

  # Returns a Bool indicating whether a jump happened
  private def jump_if_false(param_modes : Array(ParameterMode)) : Bool
    jump_if(param_modes) {|a, _| a.zero? }
  end

  private def less_than(param_modes : Array(ParameterMode))
    binary_op(param_modes) do |a, b|
      if a < b
        1_i64
      else
        0_i64
      end
    end
  end

  private def equal_to(param_modes : Array(ParameterMode))
    binary_op(param_modes) do |a, b|
      if a == b 
        1_i64 
      else 
        0_i64 
      end
    end
  end

  # Convenience method for operating on the values of two memory locations 
  # (yielding to a block) and storing the result in another memory location.
  private def binary_op(param_modes : Array(ParameterMode), &block : (Int64, Int64) -> Int64)
    operands = param_modes.first(2).map_with_index do |mode, idx| 
      read_param(mode, idx + 1)
    end

    result = (yield operands[0], operands[1])

    if DEBUG
    puts "  operands: #{operands}, result: #{result}"
    end

    write_result(3, result)
  end

  # Convenience method for grabbing two values, doing a boolean test, and then jumping if needed
  private def jump_if(param_modes : Array(ParameterMode), &block : (Int64, Int64) -> Bool)
    operands = param_modes.first(2).map_with_index do |mode, idx| 
      read_param(mode, idx + 1)
    end

    result = (yield operands[0], operands[1])

    if DEBUG
    puts "  operands: #{operands}, result: #{result}"
    end

    @instruction_pointer = operands[1] if result
    return result
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

  private def write_result(param_number : Int32, value : Int64)
    destination = @program[@instruction_pointer + param_number]
    puts "Writing #{value} to location #{destination}"
    @program[destination] = value
  end
end
