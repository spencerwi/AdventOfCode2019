struct Instruction
  getter direction
  getter distance

  def initialize(@direction : Char, @distance : Int32)
  end

  def self.parse(str : String)
    direction = str[0]
    distance = str[1...].to_i
    Instruction.new(direction, distance) 
  end
end

struct Point
  getter x, y
  def initialize(@x : Int32, @y : Int32)
  end

  def adjacent_point(direction : Char) : Point
    new_x, new_y = 
      case direction
      when 'U' then {@x, @y + 1}
      when 'R' then {@x + 1, @y}
      when 'L' then {@x - 1, @y}
      when 'D' then {@x, @y - 1}
      else raise "Unrecognized direction: #{direction}"
      end
    Point.new(new_x, new_y)
  end

  def distance_from_center : Int32
    @x.abs + @y.abs
  end
end

class LineFollower
  @instructions : Array(Instruction)
  @points_seen : Hash(Point, Int32)
  @current_point : Point
  @current_steps_taken : Int32

  getter points_seen

  def initialize(@instructions)
    @points_seen = Hash(Point, Int32).new
    @current_point = Point.new(0, 0)
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

  # After stepping to a new point, record that we went to that point, and how 
  # many steps we took before getting there.
  private def step(direction : Char)
    @current_point = @current_point.adjacent_point(direction)
    @current_steps_taken += 1
    @points_seen[@current_point] = @current_steps_taken
  end
end

class Day3

  @input : Array(Array(Instruction))
  @line1 : LineFollower
  @line2 : LineFollower
  @intersections : Set(Point)

  def initialize(wires : Array(String))
    @input = wires.map do |wire_str|
      wire_str.split(",").map {|s| Instruction.parse(s)}
    end

    @line1, @line2 = @input.map {|instructions| LineFollower.new(instructions)}
    [@line1, @line2].each(&.run)

    # Find all intersections by pure set-logic: all the points visited by both.
    @intersections = @line1.points_seen.keys.to_set & @line2.points_seen.keys.to_set
  end

  # Problem statement: find the closest intersection to the origin (point 0,0).
  def part1
    return @intersections.min_of(&.distance_from_center)
  end

  # Problem statement: find the intersection that happened after the fewest 
  # combined steps taken by both "line runners".
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
