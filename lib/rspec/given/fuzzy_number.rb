
module RSpec
  module Given
    module Fuzzy
      class FuzzyNumber         # :nodoc:

        DEFAULT_EPSILON = 10 * Float::EPSILON

        def initialize(number)
          @number = number
          @delta = number * DEFAULT_EPSILON
        end

        def ==(other)
          (other - @number).abs <= @delta
        end

        def to_s
          "<Approximately #{@number} +/- #{@delta}>"
        end

        def delta(delta)
          @delta = delta
          self
        end

        def percent(percentage)
          @delta = @number = (percentage / 100.0)
          self
        end

        def epsilon(neps)
          @delta = @number * (neps * Float::EPSILON)
          self
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
end
