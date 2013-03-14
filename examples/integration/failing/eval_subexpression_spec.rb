require 'rspec/given'

describe "Then with nesting" do
  use_natural_assertions
  Given(:index) { 1 }
  Given(:value) { "X" }
  Given(:array) { ["a", "b", "c"] }
  Then { array[index].upcase == value  }
end
