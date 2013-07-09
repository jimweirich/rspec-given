
module Minitest
  module Given

    # Framework adapter for Minitest/Given
    #
    class Framework
      def start_evaluation
        @starting_assertion_count = example.assertions
      end

      def explicit_assertions?
        example.assertions > @starting_assertion_count
      end

      def count_assertion
        example.assertions += 1
      end

      def fail_with(*args)
        raise Minitest::Assertion, args.join(" ")
      end

      def pending_error
        Minitest::Skip
      end

      private

      def example
        Minitest::Spec.current
      end
    end
  end
end

Given.framework = Minitest::Given::Framework.new
