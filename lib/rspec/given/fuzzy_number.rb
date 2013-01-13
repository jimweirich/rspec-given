
module RSpec
  module Given
    module Fuzzy
      class FuzzyNumber         # :nodoc:

        DEFAULT_EPSILON = 10 * Float::EPSILON

        def initialize(number, options=nil)
          @number = number
          case options
          when Numeric
            @delta = options
          when Hash
            @delta = delta_from_options(options, number)
          end
          @delta ||= (number * DEFAULT_EPSILON)
        end

        def ==(other)
          (other - @number).abs <= @delta
        end

        def to_s
          "<Approximately #{@number} +/- #{@delta}>"
        end

        private

        OPTIONS = {
          epsilon: ->(neps, number)    { number * (neps * Float::EPSILON) },
          percent: ->(percent, number) { number * (percent / 100.0) },
          delta:   ->(delta, number)   { delta },
        }

        def delta_from_options(options, number)
          validate_hash_options(options)
          key = options.keys.first
          OPTIONS[key].(options[key], number)
        end

        def validate_hash_options(options)
          validate_only_one_option(options)
          validate_known_options(options)
        end

        def validate_only_one_option(options)
          if options.size < 1
            fail ArgumentError, "No options given"
          end
          if options.size > 1
            fail ArgumentError, "Too many options: '#{options.keys.join(', ')}'"
          end
        end

        VALID_KEYS = OPTIONS.keys

        def validate_known_options(options)
          options.keys.each do |k|
            if ! VALID_KEYS.include?(k)
              fail ArgumentError, "Invalid option: '#{k}'"
            end
          end
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
