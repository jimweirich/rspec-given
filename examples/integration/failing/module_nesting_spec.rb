require 'rspec/given'

module Nesting
  X = 1
end

module Nesting
  describe "Then with nesting" do
    use_natural_assertions
    Given(:z) { 2 }
    Then { X == z }
  end
end
