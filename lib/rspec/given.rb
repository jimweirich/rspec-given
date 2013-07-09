require 'rspec'
require 'given'

module RSpec
  module Given
  end
end

if Given::NATURAL_ASSERTIONS_SUPPORTED
  require 'rspec/given/monkey'
  raise "Unsupported version of RSpec (unable to detect assertions)" unless RSpec::Given::MONKEY
end

require 'rspec/given/have_failed'
require 'rspec/given/before_extensions'
require 'rspec/given/framework'
require 'rspec/given/configure'

module Given
  def self.using_old_rspec?
    defined?(Spec) &&
      defined?(Spec::VERSION) &&
      defined?(Spec::VERSION::SUMMARY) &&
      Spec::VERSION::SUMMARY =~ /^rspec +1\./
  end
end

raise "Unsupported version of RSpec" if Given.using_old_rspec?
