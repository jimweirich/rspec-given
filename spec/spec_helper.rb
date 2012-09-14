require 'rspec/given'

RSpec.configure do |config|
#  config.mock_with :flexmock
  config.include(FlexMock::MockContainer)
end
