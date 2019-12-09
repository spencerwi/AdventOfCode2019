class SpaceImage
  @layers : Array(Array(Array(Int32)))

  getter layers
  def initialize(@width : Int32, @height : Int32, @data : Array(Int32))
    @layers = @data.in_groups_of(@width, 0).in_groups_of(@height, [] of Int32)
  end
end

class Day8
  def initialize(@input : Array(Int32))
  end

  def part1
    image = SpaceImage.new(25, 6, @input)
    layer_with_fewest_zeroes = image.layers.min_by {|layer| layer.flatten.count(&.zero?)}
    counts = layer_with_fewest_zeroes.flatten
      .group_by(&.itself)
      .transform_values(&.size)

    return counts[1] * counts[2]
  end

  def part2
    # TODO: this!
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day8 = Day8.new(File.read("input.txt").strip.chars.map(&.to_i))
  puts "Part 1: #{day8.part1}"
  #puts "Part 2: #{day8.part2}"
end
