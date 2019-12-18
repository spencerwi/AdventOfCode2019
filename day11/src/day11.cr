require "./IntcodeComputer"

enum Color
  Black,
  White

  def to_s
    case self
    when Black then " "
    when White then "#"
    end.not_nil!
  end
end

enum TurnDirection
  Left,
  Right
end

enum GridDirection
  North,
  South,
  East,
  West

  def turn(turn_direction : TurnDirection) : GridDirection
    case {self, turn_direction}
    when {North, TurnDirection::Left} then West
    when {North, TurnDirection::Right} then East
    when {East,  TurnDirection::Left} then North
    when {East,  TurnDirection::Right} then South
    when {South, TurnDirection::Left} then East
    when {South, TurnDirection::Right} then West
    when {West,  TurnDirection::Left} then South
    when {West,  TurnDirection::Right} then North
    else raise "Invalid direction combo: {#{self}, #{turn_direction}}"
    end
  end
end

alias Point = Tuple(Int32, Int32)

class Robot
  @direction_facing : GridDirection
  @current_location : Point
  @squares_painted : Hash(Point, Color)
  @output_idx = 0

  getter squares_painted

  def initialize(program : Array(Int64), start_panel_color : Color = Color::Black)
    @computer = YieldingIntcodeComputer.new(
      program, 
      "Robot Computer",
      ->() { decide_input },
      ->(output : Int64) { handle_computer_output(output) }
    )
    @direction_facing = GridDirection::North
    @current_location = {0, 0}
    @squares_painted = Hash(Point, Color).new(Color::Black)
    @squares_painted[{0,0}] = start_panel_color
  end

  def run
    @computer.run
  end

  private def decide_input : Int64
    case @squares_painted[@current_location]
    when Color::Black then 0_i64
    when Color::White then 1_i64
    end.not_nil!
  end

  private def handle_computer_output(computer_output : Int64) : Nil
    if @output_idx.even?
      # every output pair's first output tells us which color to paint the current square
      color = Color.new(computer_output.to_i32) 
      @squares_painted[@current_location] = color
    else
      # every output pair's second output tells us direction to turn
      turn_direction = TurnDirection.new(computer_output.to_i32)
      @direction_facing = @direction_facing.turn(turn_direction)
      step_forward
    end
    @output_idx += 1
  end

  private def step_forward
    x, y = @current_location
    @current_location = 
      case @direction_facing
      when GridDirection::North then {x,     y - 1}
      when GridDirection::West  then {x - 1, y}
      when GridDirection::East  then {x + 1, y}
      when GridDirection::South then {x,     y + 1}
      end.not_nil!
  end
end

class Day11
  def initialize(@input : Array(Int64))
  end

  def part1
    robot = Robot.new(@input)
    robot.run
    robot.squares_painted.size
  end

  def part2
    robot = Robot.new(@input, Color::White)
    robot.run
    all_points_painted = robot.squares_painted.keys
    min_y, max_y = all_points_painted.minmax_of(&.[1])
    min_x, max_x = all_points_painted.minmax_of(&.[0])

    (min_y..max_y).each do |y|
      (min_x..max_x).each do |x|
        print robot.squares_painted[{x,y}].to_s
      end
      print "\n"
    end
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day11 = Day11.new(File.read("input.txt").split(",").map(&.to_i64))
  puts "Part 1: #{day11.part1}"
  puts "Part 2: #{day11.part2}"
end
