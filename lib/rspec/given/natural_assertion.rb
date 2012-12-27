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

    class NaturalAssertion

      def initialize(block, env, line_extractor)
        @block = block
        @env = env
        @line_extractor = line_extractor
        set_file_and_line
      end

      def using_should?
        source =~ /\.should(_not)?\b/
      end

      def message
        @output = "Then expression failed at #{@code_file}:#{@code_line}\n"
        explain_failure
        display_pairs(expression_value_pairs)
        @output << "\n"
        @output
      end

      private

      BINARY_EXPLAINATIONS = {
        :== => "to equal",
        :!= => "to not equal",
        :<  => "to be less than",
        :<= => "to be less or equal to",
        :>  => "to be greater than",
        :>= => "to be greater or equal to",
        :=~ => "to match",
        :!~ => "to not match",
      }

      def explain_failure
        sexp = assertion_sexp[2]
        if sexp.first == :binary && msg = BINARY_EXPLAINATIONS[sexp[2]]
          @output << explain_expected("expected", sexp[1], msg, sexp[3])
        end
      end

      def explain_expected(expect_msg, expect_sexp, got_msg, got_sexp)
        width = [expect_msg.size, got_msg.size].max
        sprintf("%#{width}s: %s\n%#{width}s: %s\n",
          expect_msg, eval_sexp(expect_sexp),
          got_msg, eval_sexp(got_sexp))
      end

      def expression_value_pairs
        assertion_subexpressions.map { |exp|
          [exp, eval_in(exp, @env)]
        }
      end

      def assertion_subexpressions
        Sorcerer.subexpressions(assertion_sexp).reverse.uniq.reverse
      end

      def assertion_sexp
        @assertion_sexp ||= extract_test_expression(Ripper::SexpBuilder.new(source).parse)
      end

      def source
        @line_extractor.line(@code_file, @code_line)
      end

      def set_file_and_line
        @code_file, @code_line = eval "[__FILE__, __LINE__]", @block.binding
        @code_line = @code_line.to_i
      end

      def extract_test_expression(sexp)
        sexp[1][2][2][2]
      end

      def eval_sexp(sexp)
        expr = Sorcerer.source(sexp)
        eval_in(expr, @env)
      end

      def eval_in(exp, binding)
        eval(exp, binding).inspect
      rescue StandardError => ex
        EvalErr.new("#{ex.class}: #{ex.message}")
      end

      WRAP_WIDTH = 20

      def display_pairs(pairs)
        width = suggest_width(pairs)
        pairs.each do |x, v|
          fmt = (v.size > WRAP_WIDTH) ?
            "  %-#{width+2}s\n  #{' '*(width+2)} <- %s\n" :
            "  %-#{width+2}s <- %s\n"
          @output << sprintf(fmt, v, x)
        end
      end

      def suggest_width(pairs)
        pairs.map { |x,v| v.size }.select { |n| n < WRAP_WIDTH }.max || 10
      end

    end

  end
end
