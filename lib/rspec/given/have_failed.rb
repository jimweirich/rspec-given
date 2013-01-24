require 'rspec'

module RSpec
  module Given
    module HaveFailed

      # Specializes the RaiseError matcher to handle
      # Failure/non-failure objects.

      # The implementation of RaiseError changed between RSpec 2.11 and 2.12.
      if RSpec::Matchers::BuiltIn::RaiseError.instance_methods.include?(:does_not_match?)

        class HaveFailedMatcher < RSpec::Matchers::BuiltIn::RaiseError
          def matches?(given_proc, negative_expectation = false)
            if given_proc.is_a?(Failure)
              super
            else
              super(lambda { }, negative_expectation)
            end
          end

          def does_not_match?(given_proc)
            if given_proc.is_a?(Failure)
              super(given_proc)
            else
              super(lambda { })
            end
          end

          def to_s
            "<Failure matching #{@expected_error}: #{@expected_message.inspect}>"
          end
        end

      else

        class HaveFailedMatcher < RSpec::Matchers::BuiltIn::RaiseError
          def matches?(given_proc)
            if given_proc.is_a?(Failure)
              super
            else
              super(lambda { })
            end
          end

          def to_s
            "<FailureMatcher on #{@expected_error}: #{@expected_message.inspect}>"
          end
        end

      end

      # Simular to raise_error(...), but reads a bit better when using
      # a failure result from a when clause.
      #
      # Typical Usage:
      #
      #    When(:result) { fail "OUCH" }
      #    Then { result.should have_failed(StandardError, /OUCH/) }
      #
      #    When(:result) { good_code }
      #    Then { result.should_not have_failed }
      #
      # :call-seq:
      #    have_failed([exception_class [, message_pattern]])
      #    have_failed([exception_class [, message_pattern]]) { |ex| ... }
      #
      def have_failed(error=Exception, message=nil, &block)
        HaveFailedMatcher.new(error, message, &block)
      end
      alias have_raised have_failed

      def failure(error=Exception, message=nil, &block)
      end
    end
  end
end
