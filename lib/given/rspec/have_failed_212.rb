module RSpec
  module Given
    module HaveFailed

      # The RSpec-2.12 and later version of the have_failed matcher

      class HaveFailedMatcher < RSpec::Matchers::BuiltIn::RaiseError
        def matches?(given_proc, negative_expectation = false)
          if given_proc.is_a?(::Given::Failure)
            super
          else
            super(lambda { }, negative_expectation)
          end
        end

        def does_not_match?(given_proc)
          if given_proc.is_a?(::Given::Failure)
            super(given_proc)
          else
            super(lambda { })
          end
        end

        def to_s
          "<Failure matching #{@expected_error}: #{@expected_message.inspect}>"
        end
      end
    end
  end
end
