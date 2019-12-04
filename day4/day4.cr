class PasswordValidator

  # The same validator works for both part 1 and part 2, we just have to be more
  # strict about the size of repeat groups to search for in part 2.
  def self.validate(password : Int32, strict_repeat_group_size : Bool = false)
    digits = password.to_s.chars.map(&.to_i)
    return false unless digits.size == 6
    return false unless self.has_repeated_digits?(digits, strict_repeat_group_size)
    return false unless self.never_decreases?(digits)
    return true
  end

  # Check for at least onee group of consecutive repeated digits. If we're being 
  # strict about group size, we look for a group of exactly 2 consecutive 
  # repeated digits (like "22" or "11"); otherwise, we look for a group of _at 
  # least_ 2 repeated digits (like "22" or "333333" or "999" or so on).
  private def self.has_repeated_digits?(digits : Array(Int32), strict_repeat_group_size : Bool = false) : Bool
    groups_of_consecutive_repeats = 
      digits.chunks(&.itself) # chunking on &.itself means we get groups of consecutive same-digits together
            .map {|_, group| group} # chunks returns a tuple of the "common property" with the chunk itself. We just need the chunk.
            .reject {|group| group.size < 2} # And since we're looking for repeats, we only want chunks of size 2 or greater.

    # If we're being strict, we look for a chunk of _exactly_ size 2. Otherwise, _at least_ size 2.
    group_size_checker = 
      if strict_repeat_group_size
        ->(group : Array(Int32)) { group.size == 2}
      else
        ->(group : Array(Int32)) { group.size >= 2}
      end
    return groups_of_consecutive_repeats.any?(&group_size_checker)
  end

  # Check that each digit is geater than or equal to its predecessor.
  private def self.never_decreases?(digits : Array(Int32)) : Bool
    digits.each_cons(2).all? {|(a,b)| b >= a}
  end
end

class Day4
  @input_range : Range(Int32, Int32)

  def initialize(input_str : String)
    range_start, range_end = input_str.split("-").map(&.to_i)

    @input_range = (range_start..range_end)
  end

  # Problem statement: how many passwords in th given range are valid, meaning:
  #  - It must be 6 digits
  #  - It must have at least one set of consecutive repeating digits 
  #  - Digits must never decrease from left to right
  def part1 : Int32
    @input_range.count do |password|
      PasswordValidator.validate(password)
    end
  end

  # Problem statement: how many passwords in th given range are valid, meaning:
  #  - It must be 6 digits
  #  - It must have at least one set of *exactly 2* consecutive repeating digits
  #  - Digits must never decrease from left to right
  def part2 : Int32
    @input_range.count do |password|
      PasswordValidator.validate(password, strict_repeat_group_size: true)
    end
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day4 = Day4.new(File.read("input.txt"))
  puts "Part 1: #{day4.part1}"
  puts "Part 2: #{day4.part2}"
end
