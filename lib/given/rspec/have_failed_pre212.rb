module RSpec
  module Given
    module HaveFailed

      # The Pre-Rspec 2.12 version of the matcher

      class HaveFailedMatcher < RSpec::Matchers::BuiltIn::RaiseError
        def matches?(given_proc)
          if given_proc.is_a?(::Given::Failure)
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
  end
end
