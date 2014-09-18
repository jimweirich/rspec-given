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
        RSpec::Given::RaiseError::RaiseErrorMatcher.new(error, message, &block)
      end
      alias have_raised have_failed
    end
  end
end
