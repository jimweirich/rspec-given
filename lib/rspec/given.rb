module RSpec
  module Given
    def self.using_old_rspec?
      defined?(Spec) &&
        defined?(Spec::VERSION) &&
        defined?(Spec::VERSION::SUMMARY) &&
        Spec::VERSION::SUMMARY =~ /^rspec +1\./
    end
  end
end

if RSpec::Given.using_old_rspec?
  require 'rspec/given/rspec1_given'
else
  require 'rspec/given/core'
  require 'rspec/given/have_failed'
  require 'rspec/given/configure'
  require 'rspec/given/monkey'
end
