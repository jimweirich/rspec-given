$LOAD_PATH << './examples/stack'

require 'rspec/given'

RSpec.configure do |config|
  config.mock_with :flexmock
  puts "DBG: config=#{config.inspect}"
end
