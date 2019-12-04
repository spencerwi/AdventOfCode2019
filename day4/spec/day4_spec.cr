require "../day4"
require "spec"

describe PasswordValidator do

  describe ".validate" do

    it "works for sample input, using non-strict repeat group checking" do
      sample_inputs_with_expected_outputs = {
        [1,1,1,1,1,1] => true,
        [1,2,2,3,4,5] => true,
        [1,1,1,1,2,3] => true,
        [1,1,5,6,7,9] => true,
        [2,2,3,4,5,0] => false,
        [1,2,3,7,8,9] => false
      }
      sample_inputs_with_expected_outputs.each do |input, output|
        PasswordValidator.validate(input).should eq output
      end
    end

    it "works for sample input, using strict repeat group checking" do
      sample_inputs_with_expected_outputs = {
        [1,1,1,1,1,1] => false,
        [1,2,2,3,4,5] => true,
        [1,1,1,1,2,3] => false,
        [1,2,3,4,4,4] => false,
        [1,1,1,1,2,2] => true,
        [2,2,3,4,5,0] => false,
        [1,2,3,7,8,9] => false
      }
      sample_inputs_with_expected_outputs.each do |input, output|
        PasswordValidator.validate(input, strict_repeat_group_size: true).should eq output
      end
    end

  end

end
