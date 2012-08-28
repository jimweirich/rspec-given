module RSpec
  module Given
    module HaveFailed

      # Alias for raise_error(...), but reads a bit better when using
      # a failure result from a when clause.
      #
      # NOTE: This is new for 1.6.0.beta.1. A name change for this
      # method is possible.
      #
      # Typical Usage:
      #
      #    When(:result) { fail "OUCH" }
      #    Then { result.should have_failed(StandardError, /OUCH/) }
      #
      # :call-seq:
      #    have_failed([exception_class [, message_pattern]])
      #
      def have_failed(*args, &block)
        raise_error(*args, &block)
      end
    end
  end
end
