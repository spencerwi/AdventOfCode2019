require "../day1"
require "spec"

describe Day1 do
  describe "#part1" do
    it "Behaves correctly for sample input" do
      sample_inputs_with_expected_outputs = {
        ["12"] => 2,
        ["14"] => 2,
        ["1969"] => 654,
        ["100756"] => 33583,
        ["12", "14", "1969", "100756"] => (2 + 2 + 654 + 33583)
      }
      sample_inputs_with_expected_outputs.each do |input, output|
        day1 = Day1.new(input)
        day1.part1.should eq output
      end
    end
  end
  describe "#part2" do 
    it "behaves correctly for sample inputs" do
      sample_inputs_with_expected_outputs = {
        ["14"] => 2,
        ["1969"] => 966,
        ["100756"] => 50346
      }
      sample_inputs_with_expected_outputs.each do |input, output|
        day1 = Day1.new(input)
        day1.part2.should eq output
      end
    end
  end
end
