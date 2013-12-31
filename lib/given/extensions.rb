require 'given/module_methods'
require 'given/natural_assertion'
require 'given/failure'

module Given

  # Provide run-time instance methods to support Given infrastructure.
  # All the methods in this module are considered private and
  # implementation-specific, and should not be directly called by the
  # application developer.
  #
  # By convention, these private instance specific methods are
  # prefixed with _gvn_ to avoid name collisions with application
  # methods defined in a spec.
  #
  # (Note that private class methods are prefixed with _Gvn_ and
  # private instance methods are prefixed with _gvn_).
  #
  module InstanceExtensions   # :nodoc:

    # List of containing contexts in order from innermost to
    # outermost.
    def _gvn_inner_contexts    # :nodoc:
      self.class.ancestors.select { |context|
        context.respond_to?(:_Gvn_givens)
      }
    end

    # List of containing contexts in order from outermost to
    # innermost.
    def _gvn_contexts          # :nodoc:
      _gvn_inner_contexts.reverse
    end

    # Return the context information for keyword from the innermost
    # defining context.
    def _gvn_info(keyword)     # :nodoc:
      _gvn_inner_contexts.each do |context|
        h = context._Gvn_context_info
        if h.has_key?(keyword)
          return h[keyword]
        end
      end
      nil
    end

    # Should a natural assertion failure message be generated?
    #
    # A natural assertion failure message is generated if the
    # assertion has non-empty content. The configuration options for
    # natural assertions are checked and applied accordingly.
    #
    def _gvn_need_na_message?(nassert) # :nodoc:
      return false unless nassert.has_content?
      _gvn_na_configured?
    end

    # Return the configuration value for natural assertions.
    #
    # If natural assertions are not configured in the contexts, use
    # the global configuration value.
    def _gvn_na_configured?    # :nodoc:
      info_value = _gvn_info(:natural_assertions_enabled)
      info_value.nil? ? Given.natural_assertions_enabled? : info_value
    end

    # Establish all the Given preconditions the current and
    # surrounding describe/context blocks, starting with the
    # outermost context.
    def _gvn_establish_givens  # :nodoc:
      return if defined?(@_gvn_ran) && @_gvn_ran
      @_gvn_ran = true
      _gvn_contexts.each do |context|
        context._Gvn_givens.each do |block|
          instance_eval(&block)
        end
      end
    end

    # Check all the invariants in the current and surrounding
    # describe/context blocks, starting with the outermost context.
    def _gvn_check_invariants  # :nodoc:
      _gvn_contexts.each do |context|
        context._Gvn_invariants.each do |block|
          _gvn_evaluate("Invariant", block)
        end
      end
    end

    def _gvn_check_ands  # :nodoc:
      return if self.class._Gvn_context_info[:and_ran]
      self.class._Gvn_and_blocks.each do |block|
        _gvn_evaluate("And", block)
      end
      self.class._Gvn_context_info[:and_ran] = true
    end

    # Implement the run-time semantics of the Then clause.
    def _gvn_then(&block)      # :nodoc:
      _gvn_establish_givens
      _gvn_check_invariants
      _gvn_evaluate("Then", block)
      _gvn_check_ands
    end

    # Determine of the natural assertion pass/fail status of the block
    def _gvn_block_passed?(block) # :nodoc:
      passed = instance_eval(&block)
      passed = passed.to_bool if passed.respond_to?(:to_bool)
      passed
    end

    # Evaluate a Then, And, or Invariant assertion.
    def _gvn_evaluate(clause_type, block)   # :nodoc:
      Given.start_evaluation
      passed = _gvn_block_passed?(block)
      if ! Given.explicit_assertions? && _gvn_na_configured?
        _gvn_naturally_assert(clause_type, block, passed)
      end
    end

    # Naturally assert the block (based on +passed+).
    def _gvn_naturally_assert(clause_type, block, passed)
      Given.count_assertion
      unless passed
        nassert = NaturalAssertion.new(clause_type, block, self, self.class._Gvn_lines)
        Given.fail_with nassert.message if _gvn_need_na_message?(nassert)
      end
    end
  end

  # Provide run-time class methods to support Given infrastructure.
  # Methods that begin with _Gvn_ are considered private and
  # implementation specific, and should not be directly called by
  # appliation code. Other methods without the _Gvn_ prefix are public
  # and intended for use by the application developer.
  #
  # (Note that private class methods are prefixed with _Gvn_ and
  # private instance methods are prefixed with _gvn_).
  #
  module ClassExtensions

    # List of all givens directly in the current describe/context
    # block.
    def _Gvn_givens            # :nodoc:
      @_Gvn_givens ||= []
    end

    # List of all invariants directly in the current
    # describe/context block.
    def _Gvn_invariants        # :nodoc:
      @_Gvn_invariants ||= []
    end

    # List of the and blocks directly in the current describe/context
    # block.
    def _Gvn_and_blocks         # :nodoc:
      @_Gvn_and_blocks ||= []
    end

    # Context information ofr the current describe/context block.
    def _Gvn_context_info       # :nodoc:
      @_Gvn_context_info ||= {}
    end

    # Line extractor for the context.
    def _Gvn_lines              # :nodoc:
      @_Gvn_lines ||= LineExtractor.new
    end

    # Trigger the evaluation of a Given! block by referencing its
    # name.
    def _Gvn_trigger_given(name) # :nodoc:
      Proc.new { send(name) }
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
        _Gvn_givens << block
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
      _Gvn_givens << _Gvn_trigger_given(name)
    end

    # Declare the code that is under test.
    #
    # :call-seq:
    #   When(:named_result) { ... code_under_test ... }
    #   When { ... code_under_test ... }
    #
    def When(*args, &block)
      if args.first.is_a?(Symbol)
        _Gvn_when_actions_with_capture(args.first, block)
      else
        _Gvn_when_actions(block)
      end
    end

    # Normal When clause actions.
    def _Gvn_when_actions(block)        # :nodoc:
      _Gvn_before do
        _gvn_establish_givens
        instance_eval(&block)
      end
    end

    # Normal When clause actions except that exceptions are captured
    # in a Failure object.
    def _Gvn_when_actions_with_capture(name, block) # :nodoc:
      let(name) do
        Failure.capture(Given.pending_error) do
          _gvn_establish_givens
          instance_eval(&block)
        end
      end
      _Gvn_before do __send__(name) end
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
    def Then(opts={}, &block)
      on_eval = opts.fetch(:on_eval, "_gvn_then")
      file, line = Given.location_of(block)
      description = _Gvn_lines.line(file, line) unless Given.source_caching_disabled
      cmd = description ? "it(description)" : "specify"
      eval %{#{cmd} do #{on_eval}(&block) end}, binding, file, line
      _Gvn_context_info[:then_defined] = true
    end

    # Establish an invariant that must be true for all Then blocks
    # in the current (and nested) scopes.
    def Invariant(&block)
      _Gvn_invariants << block
    end

    # Provide an assertion that shares setup with a peer Then command.
    def And(&block)
      fail "And defined without a Then" unless _Gvn_context_info[:then_defined]
      _Gvn_and_blocks << block
    end

    # Configure the use of natural assertions in this context.
    def use_natural_assertions(enabled=true)
      Given.ok_to_use_natural_assertions(enabled)
      _Gvn_context_info[:natural_assertions_enabled] = enabled
    end
  end
end
