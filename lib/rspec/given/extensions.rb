require 'rspec/given/failure'
require 'rspec/given/module_methods'
require 'rspec/given/natural_assertion'

module RSpec
  module Given

    # Provide run-time methods to support RSpec/Given infrastructure.
    # All the methods in this module are considered private and
    # implementation-specific.
    module InstanceExtensions   # :nodoc:

      # List of containing contexts in order from innermost to
      # outermost.
      def _rg_inner_contexts    # :nodoc:
        self.class.ancestors.select { |context|
          context.respond_to?(:_rgc_givens)
        }
      end

      # List of containing contexts in order from outermost to
      # innermost.
      def _rg_contexts          # :nodoc:
        _rg_inner_contexts.reverse
      end

      # Return the context information for keyword from the innermost
      # defining context.
      def _rg_info(keyword)     # :nodoc:
        _rg_inner_contexts.each do |context|
          h = context._rgc_context_info
          if h.has_key?(keyword)
            return h[keyword]
          end
        end
        nil
      end

      # Should a natural assertion failure message be generated?
      #
      # A natural assertion failure message is generated if the
      # assertion has non-empty content that doesn't use rspec
      # assertions. The configuration options for natural assertions
      # are checked and applied accordingly.
      #
      def _rg_need_na_message?(nassert) # :nodoc:
        return false unless nassert.has_content?
        use_na = _rg_na_configured?
        return true if use_na == :always
        return false if !RSpec::Given::MONKEY && nassert.using_rspec_assertion?
        use_na
      end

      # Return the configuration value for natural assertions.
      #
      # If natural assertions are not configured in the contexts, use
      # the global configuration value.
      def _rg_na_configured?    # :nodoc:
        info_value = _rg_info(:natural_assertions_enabled)
        info_value.nil? ? RSpec::Given.natural_assertions_enabled? : info_value
      end

      # Establish all the Given preconditions the current and
      # surrounding describe/context blocks, starting with the
      # outermost context.
      def _rg_establish_givens  # :nodoc:
        return if defined?(@_rg_ran) && @_rg_ran
        @_rg_ran = true
        _rg_contexts.each do |context|
          context._rgc_givens.each do |block|
            instance_eval(&block)
          end
        end
      end

      # Check all the invariants in the current and surrounding
      # describe/context blocks, starting with the outermost context.
      def _rg_check_invariants  # :nodoc:
        _rg_contexts.each do |context|
          context._rgc_invariants.each do |block|
            _rg_evaluate("Invariant", block)
          end
        end
      end

      def _rg_check_ands  # :nodoc:
        return if self.class._rgc_context_info[:and_ran]
        self.class._rgc_and_blocks.each do |block|
          _rg_evaluate("And", block)
        end
        self.class._rgc_context_info[:and_ran] = true
      end

      # Implement the run-time semantics of the Then clause.
      def _rg_then(&block)      # :nodoc:
        _rg_establish_givens
        _rg_check_invariants
        _rg_evaluate("Then", block)
        _rg_check_ands
      end

      # Evaluate a Then, And, or Invariant assertion.
      def _rg_evaluate(clause_type, block)   # :nodoc:
        RSpec::Given.matcher_called = false
        passed = instance_eval(&block)
        if ! passed && _rg_na_configured? && ! RSpec::Given.matcher_called
          nassert = NaturalAssertion.new(clause_type, block, self, self.class._rgc_lines)
          RSpec::Given.fail_with nassert.message if _rg_need_na_message?(nassert)
        end
      end
    end

    module ClassExtensions

      # List of all givens directly in the current describe/context
      # block.
      def _rgc_givens            # :nodoc:
        @_rgc_givens ||= []
      end

      # List of all invariants directly in the current
      # describe/context block.
      def _rgc_invariants        # :nodoc:
        @_rgc_invariants ||= []
      end

      def _rgc_and_blocks
        @_rgc_and_blocks ||= []
      end

      def _rgc_context_info
        @_rgc_context_info ||= {}
      end

      def _rgc_lines
        @_rgc_lines ||= LineExtractor.new
      end

      # Trigger the evaluation of a Given! block by referencing its
      # name.
      def _rgc_trigger_given(name) # :nodoc:
        Proc.new { send(name) }
      end

      # *DEPRECATED:*
      #
      # The Scenario command is deprecated. Using Scenario in an
      # example will result in a warning message. Eventually the
      # command will be removed.
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
        file, line = eval("[__FILE__, __LINE__]", block.binding)
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
      #   Given(:name) { ... code ... }
      #   Given { ... code ... }
      #
      def Given(*args, &block)
        if args.first.is_a?(Symbol)
          let(args.first, &block)
        else
          _rgc_givens << block
        end
      end

      # Declare a named given of the current specification.  Similar
      # to the named version of the "Given" command, except that the
      # block is always evaluated.
      #
      # :call-seq:
      #   Given!(:name) { ... code ... }
      #
      def Given!(name, &block)
        let(name, &block)
        _rgc_givens << _rgc_trigger_given(name)
      end

      # Declare the code that is under test.
      #
      # :call-seq:
      #   When(:named_result) { ... code_under_test ... }
      #   When { ... code_under_test ... }
      #
      def When(*args, &block)
        if args.first.is_a?(Symbol)
          let!(args.first) do
            begin
              _rg_establish_givens
              instance_eval(&block)
            rescue RSpec::Given.pending_error => ex
              raise
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
      #
      # :call-seq:
      #   Then { ... assertion ... }
      #
      def Then(&block)
        env = block.binding
        file, line = eval "[__FILE__, __LINE__]", env
        description = _rgc_lines.line(file, line) unless RSpec::Given.source_caching_disabled
        if description
          cmd = "it(description)"
        else
          cmd = "specify"
        end
        eval %{#{cmd} do _rg_then(&block) end}, binding, file, line
        _rgc_context_info[:then_defined] = true
      end

      # Establish an invariant that must be true for all Then blocks
      # in the current (and nested) scopes.
      def Invariant(&block)
        _rgc_invariants << block
      end

      def And(&block)
        fail "And defined without a Then" unless _rgc_context_info[:then_defined]
        _rgc_and_blocks << block
      end

      def use_natural_assertions(enabled=true)
        RSpec::Given.ok_to_use_natural_assertions(enabled)
        _rgc_context_info[:natural_assertions_enabled] = enabled
      end
    end
  end
end
