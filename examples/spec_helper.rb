$LOAD_PATH << './examples/stack'

require 'rspec/given'

RSpec.configure do |c|
  c.mock_with :flexmock
end
