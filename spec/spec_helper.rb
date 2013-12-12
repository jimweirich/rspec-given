require 'rspec/given'

# Load the support modules.

dir = File.dirname(__FILE__)
Dir[dir + "/support/*.rb"].each do |fn|
  load fn
end

def given_assert_equal(expected, actual)
  expect(actual).to eq(expected)
end

def given_assert(cond)
  expect(cond).to be_truthy
end

def given_assert_match(pattern, actual)
  expect(actual).to match(pattern)
end

def given_assert_not_match(pattern, actual)
  expect(actual).to_not match(pattern)
end

def given_assert_raises(error, pattern=nil, &block)
  expect(&block).to raise_error(error, pattern)
end
