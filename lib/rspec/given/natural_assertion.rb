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
        subs = Sorcerer.subexpressions(assertion_sexp).reverse.uniq.reverse
        pairs = subs.map { |exp|
          [exp, eval_in(exp, @env)]
        }
        if (assertion_sexp[2][0] == :binary && assertion_sexp[2][2] == :==)
          expect_expr = Sorcerer.source(assertion_sexp[2][3])
          @output << "expected: " << eval_in(expect_expr, @env) << "\n"
          got_expr = Sorcerer.source(assertion_sexp[2][1])
          @output << "got:      " << eval_in(got_expr, @env)<< "\n"
        elsif (assertion_sexp[2][0] == :binary && assertion_sexp[2][2] == :!=)
          expect_expr = Sorcerer.source(assertion_sexp[2][3])
          @output << "expected not: " << eval_in(expect_expr, @env) << "\n"
          got_expr = Sorcerer.source(assertion_sexp[2][1])
          @output << "got:          " << eval_in(got_expr, @env)<< "\n"
        end
        display_pairs(pairs)
        @output << "\n"
        @output
      end

      private

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
