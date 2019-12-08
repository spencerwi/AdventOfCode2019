require "../day6"
require "spec"

describe Planet do

  describe ".parse_orbits" do 
    it "behaves correctly for sample input" do
      example_input = <<-INPUT
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      INPUT
      results = Planet.parse_orbits(example_input.lines)
      
      # Results should be:
      #         G - H       J - K - L
      #        /           /
      # COM - B - C - D - E - F
      #                \
      #                 I
      #
      results["COM"].should_not be_nil
      results["COM"].parent.should be_nil
      results["B"].should_not be_nil
      results["B"].parent.should eq results["COM"]
      results["G"].should_not be_nil
      results["G"].parent.should eq results["B"]
      results["H"].should_not be_nil
      results["H"].parent.should eq results["G"]
      results["C"].should_not be_nil
      results["C"].parent.should eq results["B"]
      results["D"].should_not be_nil
      results["D"].parent.should eq results["C"]
      results["I"].should_not be_nil
      results["I"].parent.should eq results["D"]
      results["E"].should_not be_nil
      results["E"].parent.should eq results["D"]
      results["F"].should_not be_nil
      results["F"].parent.should eq results["E"]
      results["J"].should_not be_nil
      results["J"].parent.should eq results["E"]
      results["K"].should_not be_nil
      results["K"].parent.should eq results["J"]
      results["L"].should_not be_nil
      results["L"].parent.should eq results["K"]
    end
  end

  describe "#count_orbits" do
    it "behaves correctly for sample inputs" do
      example_input = <<-INPUT
      COM)B
      B)G
      G)H
      B)C
      INPUT
      results = Planet.parse_orbits(example_input.lines)

      results.each_value.sum(&.count_orbits).should eq 8 
    end
  end

end

describe Day6 do 
  it "behaves correctly for sample inputs" do 
    example_input = <<-INPUT
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    INPUT
    day6 = Day6.new(example_input.lines)

    day6.part1.should eq 42
  end
end
