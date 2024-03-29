DEBUG = false

enum ParameterMode
  Position = 0,
  Immediate = 1
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
  @program : Array(Int64)
  @instruction_pointer : Int64 
  @most_recent_output : Int64?
  @has_finished : Bool

  getter program
  getter has_finished
  getter most_recent_output

  def initialize(program : Array(Int64), @input_queue : Array(Int64))
    @program = program.clone
    @instruction_pointer = 0
    @most_recent_output = nil
    @has_finished = false
  end

  def run : Int64
    loop do
      instruction = @program[@instruction_pointer]
      current_opcode, param_modes = parse_instruction(instruction)
      next_jump_amount = 0
      debug_log "Executing #{instruction} (#{current_opcode}, #{param_modes})"
      case current_opcode
      when Opcode::Quit then 
        @has_finished = true
        return @most_recent_output.not_nil!
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
      debug_log "IP: #{@instruction_pointer}, Program: #{@program}"
    end
    @has_finished = true
    return @most_recent_output.not_nil!
  end

  protected def parse_instruction(instruction : Int64) : Tuple(Opcode, Array(ParameterMode))
    modes_as_int, opcode_as_int = instruction.divmod(100)
    opcode : Opcode = Opcode.new(opcode_as_int.to_i)
    modes_digits = modes_as_int.to_s.rjust(3, '0').chars.reverse.map(&.to_i)
    param_modes : Array(ParameterMode) = 
       case opcode
       when Opcode::Quit then
         [] of ParameterMode
       when Opcode::Input, Opcode::Output then
         [ParameterMode.new(modes_digits[0])]
       when Opcode::JumpIfFalse, Opcode::JumpIfTrue then
         modes_digits.first(2).map{|it| ParameterMode.new(it)}
       else
         modes_digits.map{|it| ParameterMode.new(it)}
       end
    debug_log [opcode, param_modes]
    return {opcode, param_modes}
  end

  protected def add(param_modes : Array(ParameterMode))
    binary_op(param_modes) {|a, b| a + b}
  end

  protected def multiply(param_modes : Array(ParameterMode))
    binary_op(param_modes) {|a, b| a * b}
  end

  protected def do_input
    write_result(1, @input_queue.pop)
  end

  protected def do_output(param_mode : ParameterMode)
    result = read_param(param_mode, 1)
    @most_recent_output = result
    debug_log "output: #{result}"
  end

  # Returns a Bool indicating whether a jump happened
  protected def jump_if_true(param_modes : Array(ParameterMode)) : Bool
    jump_if(param_modes) {|a, _| !(a.zero?) }
  end

  # Returns a Bool indicating whether a jump happened
  protected def jump_if_false(param_modes : Array(ParameterMode)) : Bool
    jump_if(param_modes) {|a, _| a.zero? }
  end

  protected def less_than(param_modes : Array(ParameterMode))
    binary_op(param_modes) do |a, b|
      if a < b
        1_i64
      else
        0_i64
      end
    end
  end

  protected def equal_to(param_modes : Array(ParameterMode))
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
  protected def binary_op(param_modes : Array(ParameterMode), &block : (Int64, Int64) -> Int64)
    operands = param_modes.first(2).map_with_index do |mode, idx| 
      read_param(mode, idx + 1)
    end

    result = (yield operands[0], operands[1])

    debug_log "  operands: #{operands}, result: #{result}"

    write_result(3, result)
  end

  # Convenience method for grabbing two values, doing a boolean test, and then jumping if needed
  protected def jump_if(param_modes : Array(ParameterMode), &block : (Int64, Int64) -> Bool)
    operands = param_modes.first(2).map_with_index do |mode, idx| 
      read_param(mode, idx + 1)
    end

    result = (yield operands[0], operands[1])

    debug_log "  operands: #{operands}, result: #{result}"

    @instruction_pointer = operands[1] if result
    return result
  end

  # Convenience method for reading a parameter based on a given param mode
  protected def read_param(param_mode : ParameterMode, param_number : Int32)
    case param_mode
    when ParameterMode::Position then
      location = @program[@instruction_pointer + param_number]
      return @program[location]
    when ParameterMode::Immediate then
      return @program[@instruction_pointer + param_number]
    else raise "Invalid ParameterMode: #{param_mode}"
    end
  end

  protected def write_result(param_number : Int32, value : Int64)
    destination = @program[@instruction_pointer + param_number]
    debug_log "Writing #{value} to location #{destination}"
    @program[destination] = value
  end

  protected def debug_log(msg)
    if DEBUG
      puts msg
    end
  end
end

class NetworkedIntcodeComputer < IntcodeComputer
  @input_channel : Channel(Int64)
  @output_channel : Channel(Int64)

  getter name
  property input_channel, output_channel

  def initialize(@name : Char, @program : Array(Int64))
    super(@program, [] of Int64)
    @input_channel = Channel(Int64).new
    @output_channel = Channel(Int64).new
  end

  def run
    spawn do
      super
    end
  end

  protected def do_input
    debug_log "Waiting for input, last output was #{@most_recent_output}"
    result = @input_channel.receive
    write_result(1, result)
    debug_log "Received #{result}"
  end

  protected def do_output(param_mode : ParameterMode)
    result = read_param(param_mode, 1)
    @most_recent_output = result
    debug_log "Sending: #{result}"
    @output_channel.send(result)
  end

  protected def debug_log(msg)
    if DEBUG
      puts "#{@name}: #{msg}"
    end
  end

end
