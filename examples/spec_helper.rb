require 'rspec/given'
$LOAD_PATH << './examples/stack'

RSpec.configure do |c|
  c.mock_with :flexmock
end
