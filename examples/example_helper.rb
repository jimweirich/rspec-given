$LOAD_PATH << './examples/stack'

if ENV['FRAMEWORK'] == 'Minitest'
  require 'minitest/autorun'
  require 'minispec/given'
  require 'minitest_helper'
else
  require 'rspec/given'
  require 'spec_helper'
end
