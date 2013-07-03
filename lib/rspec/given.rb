
require 'rspec'
require 'given'

module RSpec
  module Given
  end
end

require 'rspec/given/configure'
require 'rspec/given/monkey'

module Given
  def self.using_old_rspec?
    defined?(Spec) &&
      defined?(Spec::VERSION) &&
      defined?(Spec::VERSION::SUMMARY) &&
      Spec::VERSION::SUMMARY =~ /^rspec +1\./
  end
end

raise "Unsupported version of RSpec" if Given.using_old_rspec?
