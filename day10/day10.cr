alias Point = Tuple(Int32, Int32)

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

  # Returns a Hash of the asteroids we see when look out at a specific angle
  # from a given "start asteroid". The hash key is the angle, the hash value 
  # is the coordinates of the first asteroid seen when looking that direction.
  def asteroids_seen_from_cell(x : Int32, y : Int32) : Hash(Float64, Point)
    angles_towards_asteroids_from_point({x, y})
      .transform_values(&.first)
  end

  # Returns a Hash of the asteroids as seen from a given point; the Key is the
  # angle (in degrees) towards the asteroid (with up being 0 degrees), and the
  # Value is the list of asteroids seen in that direction, sorted by distance
  # away from the given point.
  def angles_towards_asteroids_from_point(point : Point) : Hash(Float64, Array(Point))
    asteroids.reject(point)
      .sort_by {|asteroid| manhattan_distance(point, asteroid)} # closest first
      .group_by do |asteroid| 
        angle = angle_from_a_to_b(point, asteroid)
        if angle < 0
          angle += 360
        else
          angle
        end
      end
  end

  # Find the angle from point a to point b, in degrees, where 0 is "up"
  def angle_from_a_to_b(a : Point, b : Point)
    # atan2 gives you the angle between the positive x-axis and the vector from 
    # (0,0) to (x,y), in radians. Our "start point" isn't (0,0), so we offset 
    # before plugging it into atan2.
    ax, ay = a
    bx, by = b
    x_offset = bx - ax
    y_offset  = by - ay
    angle_towards_asteroid = radians_to_degrees(
      Math.atan2(y_offset.to_f, x_offset.to_f) 
    ) - 90 + 180 # - 90 because up is 0, not right, and + 180 because atan2 makes anything between 180 and 360 negative instead
  end

  private def cells_of_type(cell_type : Char)
    @spaces.each_with_index.flat_map do |(row, y)|
      row.each_with_index
        .select {|(value, x)| value == cell_type}
        .map {|(_, x)| {x, y}}
    end.to_a
  end

  def radians_to_degrees(radians : Float64) : Float64
    radians * (180/Math::PI)
  end

  def manhattan_distance(point_1 : Point, point_2 : Point) : Int32
    x1, y1 = point_1
    x2, y2 = point_2
    return (y2 - y1).abs + (x2 - x1).abs
  end
end

class Day10
  @grid : SpaceGrid

  def initialize(input_lines : Array(String))
    @grid = SpaceGrid.new(input_lines.map(&.strip).map(&.chars))
  end

  # Find the asteroid from which the most other asteroids can be seen, taking
  # into account that an asteroid blocks the view to any asteroids behind it.
  def part1 : Tuple(Point, Int32)
    @grid.asteroids.map do |(x, y)|
      asteroids_seen_from_point = @grid.asteroids_seen_from_cell(x, y)
      { {x, y}, asteroids_seen_from_point.size }
    end.max_by(&.last)
  end

  # Starting from the station coordinates found in part 1, assume you'll keep 
  # rotating a laser around clockwise from straight up, destroying asteroids 
  # (one at a time) as you go. Find the 200th asteroid destroyed, and return
  # its `(x * 100) + y`.
  def part2(station_coords : Point) : Int32
    # We'll build a queue of the asteroids we're going to destroy by getting 
    # our "radar" of asteroids, then rotating around clockwise and adding each 
    # one to the queue in order, with the nearest ones first.
    queue_of_asteroids_to_destroy = [] of Point
    all_asteroids_by_angle_and_distance = @grid.angles_towards_asteroids_from_point(station_coords)
    lists_of_asteroids_per_angle_in_clockwise_order = all_asteroids_by_angle_and_distance
      .to_a.sort_by {|angle, asteroids| angle}
      .map {|angle, asteroids| asteroids}
    idx = 0
    until lists_of_asteroids_per_angle_in_clockwise_order.flatten.empty?
      next_asteroid = lists_of_asteroids_per_angle_in_clockwise_order[idx].shift?
      queue_of_asteroids_to_destroy << next_asteroid unless next_asteroid.nil?
      idx = (idx + 1) % lists_of_asteroids_per_angle_in_clockwise_order.size
    end

    # Having gotten our queue of asteroids to destroy, we just care about the 200th one.
    target_asteroid = queue_of_asteroids_to_destroy[199]
    x, y = target_asteroid
    return (x * 100) + y
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day10 = Day10.new(File.read_lines("input.txt"))
  station_coords, asteroids_seen_from_station = day10.part1
  puts "Part 1: #{asteroids_seen_from_station}"
  puts "Station is at #{station_coords}"
  puts "Part 2: #{day10.part2(station_coords)}"
end
