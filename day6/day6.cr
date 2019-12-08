class Planet
  property parent
  getter name
  def initialize(@name : String)
  end

  def orbits(parent : Planet)
    @parent = parent
  end

  def count_orbits
    return 0 unless @parent
    direct_orbits = 1
    indirect_orbits = 0
    current = @parent.not_nil!.parent
    loop do
      break if current.nil?
      indirect_orbits += 1
      current = current.not_nil!.parent
    end
    return direct_orbits + indirect_orbits
  end

  def self.parse_orbits(input_lines : Array(String))
    planets = Hash(String, Planet).new do |hash, missing_key|
      hash[missing_key] = Planet.new(missing_key)
      hash[missing_key]
    end
    input_lines.each do |line|
      parent_name, child_name = line.split(")")
      parent, child = {planets[parent_name], planets[child_name]}
      child.orbits(parent)
    end
    return planets
  end
end

class Day6

  @planets : Hash(String, Planet)

  def initialize(input_lines : Array(String))
    @planets = Planet.parse_orbits(input_lines)
  end

  def part1
    @planets.each_value.sum(&.count_orbits)
  end

  def part2
    # TODO: this!
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day6 = Day6.new(File.read_lines("input.txt"))
  puts "Part 1: #{day6.part1}"
  #puts "Part 2: #{day6.part2}"
end
