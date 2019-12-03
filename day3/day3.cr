struct Instruction
  property direction
  property distance

  def initialize(@direction : Char, @distance : Int32)
  end

  def self.parse(str : String)
    direction = str[0]
    distance = str[1...].to_i
    Instruction.new(direction, distance) 
  end
end

alias Point = NamedTuple(x: Int32, y: Int32)

class LineFollower
  @points_seen : Hash(Point, Int32)
  @current_point : Point
  @current_steps_taken : Int32
  @instructions : Array(Instruction)

  getter points_seen

  def initialize(@instructions)
    @points_seen = Hash(Point, Int32).new
    @current_point = {x: 0, y: 0}
    @current_steps_taken = 0
  end

  def run 
    @instructions.each {|instruction| move(instruction)}
  end

  private def move(instruction : Instruction)
    instruction.distance.times do
      step(instruction.direction)
    end
  end

  private def step(direction : Char)
    next_point = 
      case direction
      when 'U' then {x: @current_point[:x], y: @current_point[:y] + 1}
      when 'R' then {x: @current_point[:x] + 1, y: @current_point[:y]}
      when 'L' then {x: @current_point[:x] - 1, y: @current_point[:y]}
      when 'D' then {x: @current_point[:x], y: @current_point[:y] - 1}
      else raise "Unrecognized direction: #{direction}"
      end

    @points_seen[next_point] = @current_steps_taken + 1
    @current_point = next_point
    @current_steps_taken += 1
  end
end

class Day3

  @input : Array(Array(Instruction))
  @line1 : LineFollower
  @line2 : LineFollower
  @intersections : Set(Point)

  def initialize(wires : Array(String))
    @input = wires.map do |wire_str|
      wire_str.split(",").map {|instr_str| Instruction.parse(instr_str)}
    end

    @line1, @line2 = @input.map {|instructions| LineFollower.new(instructions)}
    [@line1, @line2].each {|lf| lf.run}
    @intersections = @line1.points_seen.keys.to_set & @line2.points_seen.keys.to_set
  end

  def part1
    return @intersections.min_of do |p|
      p[:x].abs + p[:y].abs # get the closest manhattan distance from (0,0)
    end
  end

  def part2
    return @intersections.min_of do |p|
      @line1.points_seen[p] + @line2.points_seen[p]
    end
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day3 = Day3.new(File.read_lines("input.txt"))
  puts "Part 1: #{day3.part1}"
  puts "Part 2: #{day3.part2}"
end
