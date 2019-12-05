require "http"

def generate_day(day : Int32)
  if Dir.exists?("day#{day}")
    puts "Day #{day} already exists!"
    exit 1
  end

  Dir.mkdir("day#{day}")

  # Write solution file 
  File.write(
    "day#{day}/day#{day}.cr", 
    <<-CONTENT
    class Day#{day}
      def initialize(input_str : String)
        # TODO: this!
      end

      def part1
        # TODO: this!
      end
  
      def part2
        # TODO: this!
      end
    end

    unless PROGRAM_NAME.includes?("crystal-run-spec")
      day#{day} = Day#{day}.new(File.read("input.txt"))
      puts "Part 1: \#{day#{day}.part1}"
      #puts "Part 2: \#{day#{day}.part2}"
    end
    CONTENT
  )

  Dir.mkdir("day#{day}/spec")

  # Write spec file 
  File.write(
    "day#{day}/spec/day#{day}_spec.cr", 
    <<-CONTENT
    require "../day#{day}"
    require "spec"

    describe Day#{day} do

      describe "#part1" do 
        it "behaves correctly for sample input" do
          example_inputs_and_outputs = {
          }
          example_inputs_and_outputs.each do|input, output|
            day#{day} = Day#{day}.new(input)
            day#{day}.part1.should eq output
          end
        end
      end

    end
    CONTENT
  )
end

def download_input(day : Int32, session_cookie : String)
  headers = HTTP::Headers.new
  headers["Cookie"] = "session#{session_cookie}"
  HTTP::Client.get(
    "https://adventofcode.com/2019/day/#{day}/input",
    headers: headers
  ) do |response|
    if response.status.code == 200
      File.write("day#{day}/input.txt", response.body)
    else
      puts "Couldn't fetch input for day #{day}: [#{response.status.code}] #{response.body}"
    end
  end
end

if ARGV.size >= 1
  day = ARGV[0].to_i
  generate_day(day)
  if ARGV.size  >= 2 
    download_input(day, ARGV[1])
  end
else
  puts "Usage: newday.cr DAYNUMBER [SESSION_COOKIE_FOR_DOWNLOADING_INPUT]"
  exit 1
end
