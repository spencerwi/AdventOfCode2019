require "big" 

class SpaceGrid
  @spaces : Array(Array(Char))

  def initialize(spaces : Array(Array(Char)))
    @spaces = spaces.clone
  end

  def [](x : Int32, y : Int32)
    @spaces[y][x]
  end

  def empty_spaces
    cells_of_type('.') 
  end

  def asteroids
    cells_of_type('#') 
  end

  def asteroids_seen_from_cell(x : Int32, y : Int32) : Int32
    straight_line_asteroid_visibility = {
      "left" => false,
      "right" => false,
      "up" => false,
      "down" => false
    }
    sightlines_to_asteroids = Set(Tuple(Symbol, BigRational)).new
    asteroids.reject({x,y}).each do |a_x, a_y| 
      rise = (a_y - y)
      run = (a_x - x)
      direction = 
        case 
        when rise > 0 && run > 0 then :up_right
        when rise > 0 && run < 0 then :up_left
        when rise < 0 && run > 0 then :down_right
        else :down_left
        end

      if rise.zero? # straight horizontal line
        if run > 0
          straight_line_asteroid_visibility["right"] = true
        else
          straight_line_asteroid_visibility["left"] = true
        end
      elsif run.zero? # straight vertical line
        if rise > 0 
          straight_line_asteroid_visibility["up"] = true
        else
          straight_line_asteroid_visibility["down"] = true
        end
      else
        sightlines_to_asteroids << {direction, BigRational.new(rise, run)}
      end
    end
    diagonally_visible = sightlines_to_asteroids.size 
    straight_line_visible = straight_line_asteroid_visibility.values.count(&.itself)
    return diagonally_visible + straight_line_visible
  end

  private def cells_of_type(cell_type : Char)
    @spaces.each_with_index.flat_map do |(row, y)|
      row.each_with_index
        .select {|(value, x)| value == cell_type}
        .map {|(_, x)| {x, y}}
    end
  end
end

class Day10
  @grid : SpaceGrid

  def initialize(input_lines : Array(String))
    @grid = SpaceGrid.new(input_lines.map(&.strip).map(&.chars))
  end

  def part1
    @grid.asteroids.max_of do |x, y|
      @grid.asteroids_seen_from_cell(x, y)
    end
  end

  def part2
    # TODO: this!
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day10 = Day10.new(File.read_lines("input.txt"))
  puts "Part 1: #{day10.part1}"
  #puts "Part 2: #{day10.part2}"
end
