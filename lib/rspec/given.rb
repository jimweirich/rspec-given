
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

module RSpec
  module Given
    class Framework
      def start_evaluation
        @matcher_called = false
      end

      def explicit_assertions?
        @matcher_called
      end

      def count_assertion
      end

      def explicitly_asserted
        @matcher_called = true
      end
    end
  end
end

Given.framework = RSpec::Given::Framework.new

raise "Unsupported version of RSpec" if Given.using_old_rspec?
