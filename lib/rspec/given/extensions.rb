require 'rspec/given/failure'
require 'rspec/given/module_methods'

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

      def _rg_check_ands  # :nodoc:
        return if self.class._rg_context_info[:and_ran]
        self.class._rg_and_blocks.each do |block|
          instance_eval(&block)
        end
        self.class._rg_context_info[:and_ran] = true
      end

      # Implement the run-time semantics of the Then clause.
      def _rg_then(&block)      # :nodoc:
        _rg_establish_givens
        _rg_check_invariants
        instance_eval(&block)
        _rg_check_ands
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

      def _rg_and_blocks
        @_rg_and_blocks ||= []
      end

      def _rg_context_info
        @_rg_contet_info ||= {}
      end

      def _rg_lines
        @_rg_lines ||= LineExtractor.new
      end

      # Trigger the evaluation of a Given! block by referencing its
      # name.
      def _rg_trigger_given(name) # :nodoc:
        Proc.new { send(name) }
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
        _rg_givens << _rg_trigger_given(name)
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
        b = block.binding
        file = eval "__FILE__", b
        line = eval "__LINE__", b
        description = _rg_lines.line(file, line) unless RSpec::Given.source_caching_disabled
        if description
          cmd = "it(description)"
        else
          cmd = "specify"
        end
        eval %{#{cmd} do _rg_then(&block) end}, binding, file, line
        _rg_context_info[:then_defined] = true
      end

      # Establish an invariant that must be true for all Then blocks
      # in the current (and nested) scopes.
      def Invariant(&block)
        _rg_invariants << block
      end

      def And(&block)
        fail "And defined without a Then" unless _rg_context_info[:then_defined]
        _rg_and_blocks << block
      end
    end
  end
end
