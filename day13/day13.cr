require "./IntcodeComputer"

alias Point = Tuple(Int32, Int32)

enum TileId
  Empty = 0,
  Wall = 1,
  Block = 2,
  Paddle = 3,
  Ball = 4

  def to_char
    case self 
    when Empty then ' '
    when Wall then '#'
    when Block then '-'
    when Paddle then '_'
    when Ball then '•'
    end.not_nil!
  end
end

class Day13

  def initialize(@program : Array(Int64))
  end

  def part1
    screen = Hash(Point, TileId).new(TileId::Empty)
    current_point_x = nil
    current_point_y = nil
    computer = YieldingIntcodeComputer.new(
      @program,
      -> { 0_i64 },
      ->(output : Int64) {
        if current_point_x.nil?
          current_point_x = output.to_i32
        elsif current_point_y.nil?
          current_point_y = output.to_i32
        else
          tile_type = TileId.new(output.to_i32).not_nil!
          screen[{current_point_x.not_nil!, current_point_y.not_nil!}] = tile_type
          current_point_x = nil
          current_point_y = nil
        end
        return nil
      }
    )
    computer.run
    screen.values.count(TileId::Block)
  end

  def part2
    screen = Hash(Point, TileId).new(TileId::Empty)
    score = 0
    current_point_x = nil
    current_point_y = nil
    updated_program = @program.dup
    updated_program[0] = 2
    computer = YieldingIntcodeComputer.new(
      updated_program,
      ->{ 
        ball_x, _ = screen.key_for(TileId::Ball)
        paddle_x, _ = screen.key_for(TileId::Paddle)
        if ball_x > paddle_x
          1_i64
        elsif ball_x < paddle_x
          -1_i64
        else
          0_i64
        end
      },
      ->(output : Int64) {
        if current_point_x.nil?
          current_point_x = output.to_i32
        elsif current_point_y.nil?
          current_point_y = output.to_i32
        else
          if (current_point_x == -1_i64 && current_point_y == 0_i64)
            score = output.to_i32
          else
            tile_type = TileId.new(output.to_i32).not_nil!
            screen[{current_point_x.not_nil!, current_point_y.not_nil!}] = tile_type
          end
          current_point_x = nil
          current_point_y = nil
        end
        return nil
      }
    )
    computer.run # The game will end when all blocks are gone.
    return score
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day13 = Day13.new(File.read("input.txt").split(",").map(&.to_i64))
  puts "Part 1: #{day13.part1}"
  puts "Part 2: #{day13.part2}"
end
