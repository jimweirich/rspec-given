
module Minitest
  module Given

    # If this version of Minitest does not support the #assertions and
    # #assertions= methods, define a working version of them.
    #
    # This allows Minitest/Given to work with Minitest 4.x.
    #
    module NewAssertions
      def assertions
        _assertions
      end

      def assertions=(new_value)
        self._assertions = new_value
      end
    end
  end
end

Minitest::Spec.__send__(:include, Minitest::Given::NewAssertions)
