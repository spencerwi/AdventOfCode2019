enum DebugLevel
  None,
  Outputs,
  IO,
  Debug
end

enum ParameterMode
  Position = 0,
  Immediate = 1,
  Relative = 2
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
  RelativeBaseOffset = 9
  Quit = 99
end

class IntcodeComputer
  @program : Array(Int64)
  @instruction_pointer : Int64 
  @most_recent_output : Int64?
  @has_finished : Bool
  @relative_base : Int32
  @debug_level : DebugLevel

  getter program
  getter has_finished
  getter most_recent_output

  def initialize(program : Array(Int64), @input_queue : Array(Int64), @debug_level = DebugLevel::None)
    @program = program.clone
    @instruction_pointer = 0
    @most_recent_output = nil
    @has_finished = false
    @relative_base = 0
  end

  def run : Int64
    loop do
      instruction = @program[@instruction_pointer]
      current_opcode, param_modes = parse_instruction(instruction)
      next_jump_amount = 0
      debug_log "Executing #{instruction} (#{current_opcode}, #{param_modes})"
      case current_opcode
      when Opcode::Quit then 
        on_quit
        return @most_recent_output.not_nil!
      when Opcode::Add then 
        add(param_modes)
        next_jump_amount = 4
      when Opcode::Multiply then 
        multiply(param_modes)
        next_jump_amount = 4
      when Opcode::Input then 
        do_input(param_modes[0])
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
      when Opcode::RelativeBaseOffset
        adjust_relative_base(param_modes[0])
        next_jump_amount = 2
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
       when Opcode::Input, Opcode::Output, Opcode::RelativeBaseOffset then
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

  protected def do_input(param_mode : ParameterMode)
    write_result(param_mode, 1, @input_queue.pop)
  end

  protected def do_output(param_mode : ParameterMode)
    result = read_param(param_mode, 1)
    @most_recent_output = result
    debug_log("output: #{result}", DebugLevel::Outputs)
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

  protected def on_quit
    @has_finished = true
  end

  def adjust_relative_base(param_mode : ParameterMode)
    param = read_param(param_mode, 1)
    @relative_base += param
  end

  # Convenience method for operating on the values of two memory locations 
  # (yielding to a block) and storing the result in another memory location.
  protected def binary_op(param_modes : Array(ParameterMode), &block : (Int64, Int64) -> Int64)
    operands = param_modes.first(2).map_with_index do |mode, idx| 
      read_param(mode, idx + 1)
    end

    result = (yield operands[0], operands[1])

    debug_log "  operands: #{operands}, result: #{result}"

    write_result(param_modes[2], 3, result)
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
      return @program.fetch(location, 0_i64)
    when ParameterMode::Immediate then
      return @program.fetch(@instruction_pointer + param_number, 0_i64)
    when ParameterMode::Relative then
      offset = @program.fetch(@instruction_pointer + param_number, 0_i64)
      return @program.fetch(@relative_base + offset, 0_i64)
    else raise "Invalid ParameterMode: #{param_mode}"
    end
  end

  protected def write_result(param_mode : ParameterMode, param_number : Int32, value : Int64)
    destination = 
      if param_mode == ParameterMode::Relative
        @relative_base + @program[@instruction_pointer + param_number]
      else
        @program[@instruction_pointer + param_number]
      end
    debug_log "Writing #{value} to location #{destination} (current program size is #{@program.size}"
    # Allocate more program memory if needed
    while destination >= @program.size
      @program << 0_i64
    end
    @program[destination] = value
  end

  protected def debug_log(msg, level = DebugLevel::Debug)
    if @debug_level >= level
      puts msg
    end
  end
end

class YieldingIntcodeComputer < IntcodeComputer
  def initialize(
    program : Array(Int64), 
    @get_input_callback : Proc(Int64),
    @handle_output_callback : Proc(Int64, Nil),
    @debug_level = DebugLevel::None, 
  )
    super(program, [] of Int64, @debug_level)
    @get_input_callback = get_input_callback
    @handle_output_callback = handle_output_callback
  end

  protected def do_input(param_mode : ParameterMode)
    result = @get_input_callback.call
    write_result(param_mode, 1, result)
    debug_log("Input: #{result}", level = DebugLevel::IO)
  end

  protected def do_output(param_mode : ParameterMode)
    result = read_param(param_mode, 1)
    @most_recent_output = result
    debug_log("Output: #{result}", level = DebugLevel::Outputs)
    @handle_output_callback.call(result)
  end
end
