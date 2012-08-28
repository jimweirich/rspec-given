require 'rspec'
require 'rspec/given/extensions'
require 'rspec/given/have_failed'

RSpec.configure do |c|
  c.extend(RSpec::Given::ClassExtensions)
  c.include(RSpec::Given::InstanceExtensions)
  c.include(RSpec::Given::HaveFailed)
end
