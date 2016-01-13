require 'rspec/given'
RSpec.configure do |config|
  # Before RSpec 3.4, RSpec would only print lines in failures from spec files.
  # Starting in 3.4, it now prints lines from the new `project_source_dirs` config
  # setting. We want it to print lines from our specs instead of printing
  # `::RSpec::Expectations.fail_with(*args)` from within lib/given/rspec/framework.rb,
  # so we remove `lib` from the directories here.
  config.project_source_dirs -= ["lib"] if config.respond_to?(:project_source_dirs)
end

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

def rspec_3_or_later?
  Gem::Version.new(RSpec::Version::STRING).segments[0] >= 3
end
