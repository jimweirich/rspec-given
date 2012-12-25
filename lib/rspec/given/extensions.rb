require 'rspec/given/failure'
require 'rspec/given/module_methods'

require 'ripper'
require 'sorcerer'
module RSpec
  module Given

    class EvalErr
      def initialize(str)
        @string = str
      end
      def size
        inspect.size
      end
      def to_s
        @string
      end
      def inspect
        @string
      end
    end

    class NaturalExpression

      def initialize(block, env)
        @block = block
        @env = env
        @output = ""
      end

      def message
        file, line = caller_line(@block)
        @output << "Then expression failed at #{file}:#{line}\n"
        lines = open(file).readlines
        code = lines[line.to_i-1]
        sexp = Ripper::SexpBuilder.new(code).parse
        sexp = extract_test_expression(sexp)
        puts "DBG: sexp=#{sexp.inspect}"
        subs = Sorcerer.subexpressions(sexp).reverse.uniq.reverse
        pairs = subs.map { |exp|
          [exp, eval_in(exp, @env)]
        }
        if (sexp[2][0] == :binary && sexp[2][2] == :==)
          expect_expr = Sorcerer.source(sexp[2][3])
          @output << "expected: " << eval_in(expect_expr, @env) << "\n"
          got_expr = Sorcerer.source(sexp[2][1])
          @output << "got:      " << eval_in(got_expr, @env)<< "\n"
        end
        display_pairs(pairs)
        @output << "\n"
        @output
      end

      private

      def caller_line(block)
        eval "[__FILE__, __LINE__]", block.binding
      end

      def extract_test_expression(sexp)
        sexp[1][2][2][2]
      end

      def eval_in(exp, binding)
        eval(exp, binding).inspect
      rescue StandardError => ex
        EvalErr.new("#{ex.class}: #{ex.message}")
      end

      def suggest_width(pairs)
        pairs.map { |x,v| v.size }.select { |n| n < 20 }.max || 10
      end

      def display_pairs(pairs)
        width = suggest_width(pairs)
        pairs.each do |x, v|
          if v.size > 20
            @output << sprintf("  %-#{width+2}s\n  #{' '*(width+2)} <- %s\n", v, x)
          else
            @output << sprintf("  %-#{width+2}s <- %s\n", v, x)
          end
        end
      end

    end

  end
end


module RSpec
  module Given

    # Provide run-time methods to support RSpec/Given infrastructure.
    # All the methods in this module are considered private and
    # implementation-specific.
    module InstanceExtensions   # :nodoc:

      # List of containing contexts in order from outermost to
      # innermost.
      def _rg_contexts          # :nodoc:
        self.class.ancestors.select { |context|
          context.respond_to?(:_rg_givens)
        }.reverse
      end

      # Establish all the Given preconditions the current and
      # surrounding describe/context blocks, starting with the
      # outermost context.
      def _rg_establish_givens  # :nodoc:
        return if defined?(@_rg_ran) && @_rg_ran
        @_rg_ran = true
        _rg_contexts.each do |context|
          context._rg_givens.each do |block|
            instance_eval(&block)
          end
        end
      end

      # Check all the invariants in the current and surrounding
      # describe/context blocks, starting with the outermost context.
      def _rg_check_invariants  # :nodoc:
        _rg_contexts.each do |context|
          context._rg_invariants.each do |block|
            _rg_evaluate(block)
          end
        end
      end

      def _rg_check_ands  # :nodoc:
        return if self.class._rg_context_info[:and_ran]
        self.class._rg_and_blocks.each do |block|
          _rg_evaluate(block)
        end
        self.class._rg_context_info[:and_ran] = true
      end

      # Implement the run-time semantics of the Then clause.
      def _rg_then(&block)      # :nodoc:
        _rg_establish_givens
        _rg_check_invariants
        _rg_evaluate(block)
        _rg_check_ands
      end

      def _rg_evaluate(block)
        unless instance_eval(&block)
          nexp = NaturalExpression.new(block, binding)
          ::RSpec::Expectations.fail_with nexp.message
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

      def _rg_and_blocks
        @_rg_and_blocks ||= []
      end

      def _rg_context_info
        @_rg_context_info ||= {}
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
      #   Given(:name) { ... code ... }
      #   Given { ... code ... }
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
      #
      def Given!(name, &block)
        let!(name, &block)
        _rg_givens << _rg_trigger_given(name)
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
