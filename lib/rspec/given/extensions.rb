module RSpec
  module Given
    module Extensions

      # *DEPRECATED:*
      #
      # The Scenario command is deprecated.  Future versions of
      # rspec/given will start displaying warnings when used.
      # Eventually the command will be removed.
      #
      # Declare a scenario to contain Given/When/Then declarations.  A
      # Scenario is essentially an RSpec context, with the additional
      # expectations:
      #
      # * There is a single When declaration in a Scenario.
      # * Scenarios do not nest.
      #
      # :call-seq:
      #    Scenario "a scenario description" do ... end
      #
      def Scenario(description, &block)
        context(description, &block)
      end

      # Declare a "given" of the current specification.  If the given
      # is named, the block will be lazily evaluated the first time
      # the given is mentioned by name in the specification.  If the
      # given is unnamed, the block is evaluated for side effects
      # every time the specification is executed.
      #
      # :call-seq:
      #   Given(:name, &block)
      #   Given(&block)
      #
      def Given(*args, &block)
        if args.first.is_a?(Symbol)
          let(args.first, &block)
        else
          before(&block)
        end
      end

      # Declare a named given of the current specification.  Similar
      # to the named version of the "Given" command, except that the
      # block is always evaluated.
      #
      # :call-seq:
      #   Given!(:name) { ... code ... }
      def Given!(name, &block)
        let!(name, &block)
      end

      # Declare the code that is under test.
      #
      # :call-seq:
      #   When(:named_result, &block)
      #   When(&block)
      #
      def When(*args, &block)
        if args.first.is_a?(Symbol)
          let!(args.first, &block)
        else
          before(&block)
        end
      end
    end
  end
end
