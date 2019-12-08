class Planet
  property parent
  getter name
  def initialize(@name : String)
  end

  def orbits(parent : Planet)
    @parent = parent
  end

  def count_orbits
    return 0 if @parent.nil?
    direct_orbits = 1
    indirect_orbits = @parent.not_nil!.ancestors.size
    return direct_orbits + indirect_orbits
  end

  def ancestors : Array(Planet)
    result = [] of Planet
    current = @parent
    loop do
      break if current.nil?
      result << current
      current = current.parent
    end
    return result
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

  # Problem statement: count the number of direct and indirect orbits specified
  def part1
    @planets.each_value.sum(&.count_orbits)
  end

  # Problem statement: find the minimum distance between the object you orbit
  # and the object Santa orbits.
  def part2
    you_parent = @planets["YOU"]
    santa_parent = @planets["SAN"]
    return distance_between(you_parent, santa_parent)
  end

  private def distance_between(a : Planet, b : Planet) : Int32
    ancestors_of_a = a.ancestors
    ancestors_of_b = b.ancestors
    lowest_common_ancestor = ancestors_of_b.find do |b_ancestor|
      ancestors_of_a.includes?(b_ancestor)
    end
    if lowest_common_ancestor.nil?
      raise "Something went wrong!"
    else
      hops_from_b = ancestors_of_b.index(lowest_common_ancestor).not_nil!
      hops_from_a = ancestors_of_a.index(lowest_common_ancestor).not_nil!
      return hops_from_b + hops_from_a
    end
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day6 = Day6.new(File.read_lines("input.txt"))
  puts "Part 1: #{day6.part1}"
  puts "Part 2: #{day6.part2}"
end
