require 'rspec/given/version'
require 'rspec/given/extensions'

class Spec::ExampleGroup
  extend RSpec::Given::ClassExtensions
  include RSpec::Given::InstanceExtensions

  class << self
    alias Then specify
  end
end
