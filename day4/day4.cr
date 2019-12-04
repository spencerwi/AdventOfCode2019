class PasswordValidator

  # The same validator works for both part 1 and part 2, we just have to be more
  # strict about the size of repeat groups to search for in part 2.
  def self.validate(digits : Array(Int32), strict_repeat_group_size : Bool = false)
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
    count_possibly_valid_passwords do |password|
      PasswordValidator.validate(password)
    end
  end

  # Problem statement: how many passwords in th given range are valid, meaning:
  #  - It must be 6 digits
  #  - It must have at least one set of *exactly 2* consecutive repeating digits
  #  - Digits must never decrease from left to right
  def part2 : Int32
    count_possibly_valid_passwords do |password|
      PasswordValidator.validate(password, strict_repeat_group_size: true)
    end
  end

  # We only need to iterate over numbers where:
  # - There are 6 digits
  # - None of those digits are smaller than the preceding digit
  # So we can optimize by never iterating numbers that don't match that pattern.
  private def count_possibly_valid_passwords(&validator : (Array(Int32)) -> Bool) : Int32
    return 0 if @input_range.end < 100_000 # Then there'd be no 6-digit numbers
    return 0 if @input_range.begin >= 1_000_000 # Then there'd be no 6-digit numbers
    valid_password_count = 0

    digits_in_start_of_range = @input_range.begin.to_s.chars.map(&.to_i)
    (digits_in_start_of_range[0]..9).each do |a| # digit 1
      (a..9).each do |b| # digit 2
        (b..9).each do |c| # digit 3
          (c..9).each do |d| # digit 4
            (d..9).each do |e| # digit 5
              (e..9).each do |f| # digit 6
                digits = [a,b,c,d,e,f]
                password = digits.join("").to_i
                if @input_range.includes?(password) # In case we got, like, 123456, then 111111 shouldn't be valid.
                  is_valid = (yield digits)
                  valid_password_count += 1 if is_valid
                end
              end
            end
          end
        end
      end
    end
    return valid_password_count
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day4 = Day4.new(File.read("input.txt"))
  puts "Part 1: #{day4.part1}"
  puts "Part 2: #{day4.part2}"
end
