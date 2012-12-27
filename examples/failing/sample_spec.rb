require 'rspec/given'

describe "Natural Assertions" do
  Given(:foo) { 1 }
  Given(:bar) { 2 }
  Then { foo + bar == 2 }
end
