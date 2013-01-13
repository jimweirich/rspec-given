
module RSpec
  module Given
    module Fuzzy
      class FuzzyNumber         # :nodoc:

        EPSILON = 10 * Float::EPSILON

        def initialize(number, delta=nil)
          @number = number
          @delta = delta || (number * EPSILON)
        end

        def ==(other)
          (other - @number).abs <= @delta
        end

        def to_s
          "<Approximately #{@number} +/- #{@delta}>"
        end
      end

      # Create an approximate number that is approximately equal to
      # the given number, plus or minus the delta value. If no
      # explicit delta is given, then the default delta that is about
      # 10X the size of the smallest possible change in the given
      # number will be used.
      def about(number, delta=nil)
        FuzzyNumber.new(number, delta)
      end
    end
  end
end
