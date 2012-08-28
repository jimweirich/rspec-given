require 'rspec'
require 'rspec/given/extensions'
require 'rspec/given/have_failed'

RSpec.configure do |c|
  c.alias_example_to :Then
  c.extend(RSpec::Given::Extensions)
  c.include(RSpec::Given::HaveFailed)
end
