$LOAD_PATH << './examples/stack'

if defined?(RSpec)
  require 'rspec/given'
  require 'spec_helper'
else
  require 'minitest/autorun'
  require 'minitest/given'
  require 'minitest_helper'
end
