require "../day4"
require "spec"

describe PasswordValidator do
  describe ".validate" do
    it "works for sample input" do
      sample_inputs_with_expected_outputs = {
        111111 => true,
        122345 => true,
        111123 => true,
        115679 => true,
        223450 => false,
        123789 => false
      }
      sample_inputs_with_expected_outputs.each do |input, output|
        PasswordValidator.validate(input).should eq output
      end
    end
  end
end

describe Day4 do

  describe "#part1" do 
    it "behaves correctly for sample input" do
      example_inputs_and_outputs = {
        "111110-111111" => 1
      }
      example_inputs_and_outputs.each do|input, output|
        day4 = Day4.new(input)
        day4.part1.should eq output
      end
    end
  end

end
