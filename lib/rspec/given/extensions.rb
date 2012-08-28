require 'rspec/given/failure'

module RSpec
  module Given

    # Provide run-time methods to support RSpec/Given infrastructure.
    # All the methods in this module are considered private and
    # implementation-specific.
    module InstanceExtensions   # :nodoc:

      # Establish all the Given preconditions the current and
      # surrounding describe/context blocks, starting with the
      # outermost context.
      def _rg_establish_givens  # :nodoc:
        return if defined?(@_rg_ran)
        self.class.ancestors.reverse.each do |context|
          context._rg_givens.each do |block|
            instance_eval(&block)
          end
        end
        @_rg_ran = true
      end

      # Check all the invariants in the current and surrounding
      # describe/context blocks, starting with the outermost context.
      def _rg_check_invariants  # :nodoc:
        self.class.ancestors.reverse.each do |context|
          context._rg_invariants.each do |block|
            instance_eval(&block)
          end
        end
      end
    end

    module ClassExtensions

      # List of all givens directly in the current describe/context
      # block.
      def _rg_givens            # :nodoc:
        @_rg_givens ||= []
      end

      # List of all invariants directly in the current
      # describe/context block.
      def _rg_invariants        # :nodoc:
        @_rg_invariants ||= []
      end

      # *DEPRECATED:*
      #
      # The Scenario command is deprecated. Using Scenario in a spec
      # will result in a warning message. Eventually the command will
      # be removed.
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
        line = eval("__LINE__", block.binding)
        file = eval("__FILE__", block.binding)
        puts "WARNING: Scenario is deprecated, please use either describe or context (#{file}:#{line})"
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
          _rg_givens << block
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
          let!(args.first) do
            begin
              _rg_establish_givens
              instance_eval(&block)
            rescue Exception => ex
              Failure.new(ex)
            end
          end
        else
          before do
            _rg_establish_givens
            instance_eval(&block)
          end
        end
      end

      # Provide an assertion about the specification.
      #
      # Then supplies an assertion that should be true after all the
      # Given and When blocks have been run. All invariants in scope
      # will be checked before the Then block is run.
      def Then(&block)
        specify do
          _rg_establish_givens
          _rg_check_invariants
          instance_eval(&block)
        end
      end

      # Establish an invariant that must be true for all Then blocks
      # in the current (and nested) scopes.
      def Invariant(&block)
        _rg_invariants << block
      end
    end
  end
end
