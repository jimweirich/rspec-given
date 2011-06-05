require 'rspec/given/extensions'

RSpec.configure do |c|
  c.alias_example_to :Then
  c.extend(RSpec::Given::Extensions)
end
