require 'rspec/given'

# Load the support modules.

dir = File.dirname(__FILE__)
Dir[dir + "/support/*.rb"].each do |fn|
  load fn
end

def given_assert_equal(expected, actual)
  actual.should == expected
end

def given_assert(cond)
  cond.should be_true
end

def given_assert_match(pattern, actual)
  actual.should =~ pattern
end

def given_assert_not_match(pattern, actual)
  actual.should_not =~ pattern
end
