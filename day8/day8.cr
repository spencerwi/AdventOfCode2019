enum Colors
  Black = 0,
  White = 1,
  Transparent = 2

  def render_text : Char
    case self
    when Black then '.'
    when White then '#'
    when Transparent then ' '
    else raise "Invalid color: #{self}"
    end
  end
end

class SpaceImage
  @layers : Array(Array(Array(Int32)))

  getter layers
  def initialize(@width : Int32, @height : Int32, @data : Array(Int32))
    @layers = @data.in_groups_of(@width, 0).in_groups_of(@height, [] of Int32)
  end

  def get_pixel_color(x : Int32, y : Int32)
    layer_values_for_pixel = @layers.map {|layer| layer.dig?(y, x) || 0}
    top_opaque_pixel = layer_values_for_pixel.find {|x| x != Colors::Transparent.value}
    if top_opaque_pixel.nil?
      return Colors::Transparent
    else
      return Colors.new(top_opaque_pixel)
    end
  end

  def render_as_text
    (0..@height).map do |y|
      (0..@width).map do |x|
        get_pixel_color(x, y).render_text
      end.join("")
    end.join("\n")
  end
end

class Day8
  @image : SpaceImage

  def initialize(@input : Array(Int32))
    @image = SpaceImage.new(25, 6, @input)
  end

  def part1
    layer_with_fewest_zeroes = @image.layers.min_by {|layer| layer.flatten.count(&.zero?)}
    counts = layer_with_fewest_zeroes.flatten
      .group_by(&.itself)
      .transform_values(&.size)

    return counts[1] * counts[2]
  end

  def part2
    "\n#{@image.render_as_text}"
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day8 = Day8.new(File.read("input.txt").strip.chars.map(&.to_i))
  puts "Part 1: #{day8.part1}"
  puts "Part 2: #{day8.part2}"
end
