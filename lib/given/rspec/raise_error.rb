module RSpec
  module Given
    module RaiseError
      class RaiseErrorMatcher < RSpec::Matchers::BuiltIn::RaiseError
        def matches?(given_proc, negative_expectation = false)
          if given_proc.is_a?(::Given::Failure)
            super(wrap_proc_eval(given_proc), negative_expectation)
          else
            super(given_proc, negative_expectation)
          end
        end

        def does_not_match?(given_proc)
          if given_proc.is_a?(::Given::Failure)
            super(wrap_proc_eval(given_proc))
          else
            super(lambda { })
          end
        end

        def to_s
          "<Failure matching #{@expected_error}: #{@expected_message.inspect}>"
        end

        private

        def wrap_proc_eval(given_proc)
          lambda { given_proc.call }
        end
      end

      def raise_error(error=Exception, message=nil, &block)
        RaiseErrorMatcher.new(error, message, &block)
      end
    end
  end
end
