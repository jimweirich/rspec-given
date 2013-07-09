
module RSpec
  module Given

    # Framework interface for RSpec/Given.
    #
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
