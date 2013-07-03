
module Given
  module Fuzzy
    class FuzzyNumber

      DEFAULT_EPSILON = 10 * Float::EPSILON

      attr_reader :exact_value, :delta_amount

      def initialize(exact_value)
        @exact_value = exact_value
        @delta_amount = exact_value * DEFAULT_EPSILON
      end

      def exactly_equals?(other)
        other.is_a?(self.class) &&
          exact_value == other.exact_value &&
          delta_amount == other.delta_amount
      end

      # Low limit of the fuzzy number.
      def low_limit
        exact_value - delta_amount
      end

      # High limit of the fuzzy number.
      def high_limit
        exact_value + delta_amount
      end

      # True if the other number is in range of the fuzzy number.
      def ==(other)
        (other - exact_value).abs <= delta_amount
      end

      def to_s
        "<Approximately #{exact_value} +/- #{delta_amount}>"
      end

      # Set the delta for a fuzzy number.
      def delta(delta)
        @delta_amount = delta.abs
        self
      end

      # Specifying a percentage of the exact number to be used in
      # setting the delta.
      def percent(percentage)
        delta(exact_value * (percentage / 100.0))
      end

      # Specifying the number of epsilons to be used in setting the
      # delta.
      def epsilon(neps)
        delta(exact_value * (neps * Float::EPSILON))
      end
    end

    # Create an approximate number that is approximately equal to
    # the given number, plus or minus the delta value. If no
    # explicit delta is given, then the default delta that is about
    # 10X the size of the smallest possible change in the given
    # number will be used.
    def about(*args)
      FuzzyNumber.new(*args)
    end
  end
end
