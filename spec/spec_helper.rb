require 'rspec/given'

RSpec.configure do |config|
  config.mock_with :flexmock
  puts "DBG: config=#{config.inspect}"
  config.include FlexMock::MockContainer
  config.include_or_extend_modules.each do |ccc| puts "DBG: ccc=#{ccc.inspect}" end
  puts "DBG: RSpec::Core::MockFrameworkAdapter.instance_methods=#{RSpec::Core::MockFrameworkAdapter.instance_methods.grep(/flex/).inspect}"
end

describe "SAMPLE" do
  puts "DBG: in SAMPLE instance_methods=#{instance_methods.grep(/flex/).inspect}"
end
