require 'rspec/given/version'
require 'rspec/given/extensions'

class Spec::ExampleGroup
  extend RSpec::Given::Extensions

  class << self
    alias Then specify
  end
end
