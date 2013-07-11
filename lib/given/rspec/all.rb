require 'rspec'
require 'given'

module RSpec
  module Given
  end
end

if Given::NATURAL_ASSERTIONS_SUPPORTED
  require 'given/rspec/monkey'
  raise "Unsupported version of RSpec (#{RSpec::Version::STRING}), unable to detect assertions" unless RSpec::Given::MONKEY
end

require 'given/rspec/have_failed'
require 'given/rspec/before_extensions'
require 'given/rspec/framework'
require 'given/rspec/use_natural_assertions'
require 'given/rspec/configure'

module Given
  def self.using_old_rspec?
    defined?(Spec) &&
      defined?(Spec::VERSION) &&
      defined?(Spec::VERSION::SUMMARY) &&
      Spec::VERSION::SUMMARY =~ /^rspec +1\./
  end
end

raise "Unsupported version of RSpec" if Given.using_old_rspec?
