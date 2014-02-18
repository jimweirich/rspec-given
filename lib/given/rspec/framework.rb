
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

      def fail_with(*args)
        ::RSpec::Expectations.fail_with(*args)
      end

      # Use the RSpec pending error if we can find it.
      if defined?(RSpec::Core::Pending::PendingDeclaredInExample)
        def pending_error
          RSpec::Core::Pending::PendingDeclaredInExample
        end
      elsif defined?(RSpec::Core::Pending::SkipDeclaredInExample)
        def pending_error
          RSpec::Core::Pending::SkipDeclaredInExample
        end
      else
        PendingError = Class.new(StandardError)
        def pending_error
          PendingError
        end
      end
    end
  end
end

Given.framework = RSpec::Given::Framework.new
