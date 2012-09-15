require 'rspec/given'

RSpec.configure do |config|
  config.mock_with :flexmock
  puts "DBG: config=#{config.inspect}"
  config.include_or_extend_modules.each do |ccc| puts "DBG: ccc=#{ccc.inspect}" end
end
