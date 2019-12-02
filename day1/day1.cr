class Day1

  @input : Array(Int32)

  def initialize(input_str : Array(String))
    @input = input_str.map {|m| m.to_i}
  end

  def part1
    @input.map {|m| calculate_fuel_requirements(m)}.sum
  end

  def part2
    @input.map do |m|
      total_fuel_requirement = 0
      additional_weight_to_carry = m
      loop do
        additional_weight_to_carry = calculate_fuel_requirements(additional_weight_to_carry)
        break if additional_weight_to_carry <= 0
        total_fuel_requirement += additional_weight_to_carry
      end
      total_fuel_requirement
    end.sum
  end

  private def calculate_fuel_requirements(weight : Int32) : Int32
    ((weight / 3).floor - 2).to_i
  end
end

day1 = Day1.new(File.read_lines("input.txt"))
puts "Part 1: #{day1.part1}"
puts "Part 2: #{day1.part2}"
