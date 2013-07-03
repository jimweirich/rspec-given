$LOAD_PATH << './examples/stack'

if ENV['FRAMEWORK'] == 'Minitest'
  require 'minitest/autorun'
  require 'minitest/spec'
  require 'minitest/given'
  require 'flexmock/test_unit'
  require 'minitest_helper'
else
  require 'rspec/given'
  require 'spec_helper'
end
