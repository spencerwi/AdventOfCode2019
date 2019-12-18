alias Point = Tuple(Int32, Int32, Int32)
alias Velocity = Tuple(Int32, Int32, Int32)

def add_tuples(t1 : Tuple(Int32, Int32, Int32), t2 : Tuple(Int32, Int32, Int32))
  return {
    t1[0] + t2[0],
    t1[1] + t2[1],
    t1[2] + t2[2]
  }
end

class Moon
  @velocity : Velocity
  getter position, velocity

  def initialize(@position : Point)
    @velocity = {0, 0, 0}
  end

  def apply_gravity_towards(other : Point)
    velocity_change = @position.map_with_index do |own_coord, idx|
      get_change_along_axis(own_coord, other[idx])
    end
    @velocity = add_tuples(@velocity, velocity_change)
  end

  def apply_velocity
    @position = add_tuples(@position, @velocity)
  end

  def potential_energy
    @position.map(&.abs).sum
  end

  def kinetic_energy
    @velocity.map(&.abs).sum
  end

  def total_energy
    potential_energy * kinetic_energy
  end
  
  private def get_change_along_axis(own_value : Int32, other_point_value_on_axis : Int32)
    if own_value > other_point_value_on_axis
      -1
    elsif own_value < other_point_value_on_axis
      1
    else
      0
    end
  end

  def self.parse(descriptor : String) : Moon
    if /<x=(?<x>-?\d+), y=(?<y>-?\d+), z=(?<z>-?\d+)>/.match(descriptor) 
      x = $~["x"].to_i32
      y = $~["y"].to_i32
      z = $~["z"].to_i32
      Moon.new({x,y,z})
    else 
      raise "Invalid Moon descriptor: #{descriptor}"
    end
  end
end

class Day12
  def initialize(@input_lines : Array(String))
  end

  def part1
    moons = @input_lines.map {|line| Moon.parse(line)}
    1000.times { simulate_step(moons) }
    moons.map(&.total_energy).sum
  end

  def part2
    seen_states = Set(Array(Tuple(Point, Velocity))).new
    moons = @input_lines.map {|line| Moon.parse(line)}
    step_count = 0
    loop do
      current_state : Array(Tuple(Point, Velocity)) = moons.map {|moon| { moon.position, moon.velocity } }
      puts current_state

      return step_count if seen_states.includes?(current_state)

      seen_states << current_state
      simulate_step(moons)
      step_count += 1
    end
  end

  private def simulate_step(moons : Array(Moon))
    apply_gravity(moons)
    moons.each(&.apply_velocity)
  end

  private def apply_gravity(moons : Array(Moon))
    moons.each_combination(2) do |(moon1, moon2)|
      moon1.apply_gravity_towards(moon2.position)
      moon2.apply_gravity_towards(moon1.position)
    end
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day12 = Day12.new(File.read_lines("input.txt"))
  puts "Part 1: #{day12.part1}"
#  puts "Part 2: #{day12.part2}"
end
