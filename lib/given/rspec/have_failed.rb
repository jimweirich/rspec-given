
# The implementation of RaiseError changed between RSpec 2.11 and 2.12.
if RSpec::Matchers::BuiltIn::RaiseError.instance_methods.include?(:does_not_match?)
  require 'given/rspec/have_failed_212.rb'
else
  require 'given/rspec/have_failed_pre212.rb'
end

module RSpec
  module Given
    module HaveFailed

      # Specializes the RaiseError matcher to handle
      # Failure/non-failure objects.

      # Simular to raise_error(...), but reads a bit better when using
      # a failure result from a when clause.
      #
      # Typical Usage:
      #
      #    When(:result) { fail "OUCH" }
      #    Then { expect(result).to have_failed(StandardError, /OUCH/) }
      #
      #    When(:result) { good_code }
      #    Then { expect(result).to_not have_failed }
      #
      # :call-seq:
      #    have_failed([exception_class [, message_pattern]])
      #    have_failed([exception_class [, message_pattern]]) { |ex| ... }
      #
      def have_failed(error=Exception, message=nil, &block)
        HaveFailedMatcher.new(error, message, &block)
      end
      alias have_raised have_failed
    end
  end
end
