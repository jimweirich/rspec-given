require 'given/module_methods'
require 'given/evaluator'
require 'given/binary_operation'

if Given::NATURAL_ASSERTIONS_SUPPORTED
  require 'ripper'
  require 'sorcerer'
end

module Given

  InvalidThenError = Class.new(StandardError)

  class NaturalAssertion

    def initialize(clause_type, block, example, line_extractor)
      @clause_type = clause_type
      @evaluator = Evaluator.new(example, block)
      @line_extractor = line_extractor
      set_file_and_line(block)
    end

    VOID_SEXP = [:void_stmt]

    def has_content?
      assertion_sexp != VOID_SEXP
    end

    def message
      @output = "#{@clause_type} expression failed at #{source_line}\n"
      @output << "Failing expression: #{source.strip}\n" if @clause_type != "Then"
      explain_failure
      display_pairs(expression_value_pairs)
      @output << "\n"
      @output
    end

    private

    def explain_failure
      binary = BinaryOperation.parse(assertion_sexp)
      if binary && binary.explain
        @output << explain_expected("expected", binary.left, binary.explain, binary.right)
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
        [exp, @evaluator.eval_string(exp)]
      }
    end

    def assertion_subexpressions
      Sorcerer.subexpressions(assertion_sexp).reverse.uniq.reverse
    end

    def assertion_sexp
      @assertion_sexp ||= extract_test_expression(Ripper::SexpBuilder.new(source).parse)
    end

    def source
      @source ||= @line_extractor.line(@code_file, @code_line)
    end

    def set_file_and_line(block)
      @code_file, @code_line = @evaluator.location
      @code_line = @code_line.to_i
    end

    def extract_test_expression(sexp)
      brace_block = extract_brace_block(sexp)
      extract_first_statement(brace_block)
    end

    def extract_brace_block(sexp)
      unless then_block?(sexp)
        source = Sorcerer.source(sexp)
        fail InvalidThenError, "Unexpected code at #{source_line}\n#{source}"
      end
      sexp[1][2][2]
    end

    def then_block?(sexp)
      program_sexp?(sexp) && method_with_block?(sexp) && has_block_sexp?(sexp)
    end

    def program_sexp?(sexp)
      delve(sexp,0) == :program
    end

    def method_with_block?(sexp)
      delve(sexp,1,0) == :stmts_add &&
        delve(sexp,1,2,0) == :method_add_block
    end

    def has_block_sexp?(sexp)
      delve(sexp,1,2,2,0) == :brace_block || delve(sexp,1,2,2,0) == :do_block
    end

    def extract_first_statement(block_sexp)
      if contains_multiple_statements?(block_sexp)
        source = Sorcerer.source(block_sexp)
        fail InvalidThenError, "Multiple statements in Then block at #{source_line}\n#{source}"
      end
      extract_statement_from_block(block_sexp)
    end

    def contains_multiple_statements?(block_sexp)
      !(delve(block_sexp,2,0) == :stmts_add &&
        delve(block_sexp,2,1,0) == :stmts_new)
    end

    def extract_statement_from_block(block_sexp)
      delve(block_sexp,2,2)
    end

    # Safely dive into an array with a list of indicies. Return nil
    # if the element doesn't exist, or if the intermediate result is
    # not indexable.
    def delve(ary, *indicies)
      result = ary
      while !indicies.empty? && result
        return nil unless result.respond_to?(:[])
        i = indicies.shift
        result = result[i]
      end
      result
    end

    def eval_sexp(sexp)
      expr_string = Sorcerer.source(sexp)
      @evaluator.eval_string(expr_string)
    end

    WRAP_WIDTH = 20

    def display_pairs(pairs)
      width = suggest_width(pairs) + 4
      pairs.each do |x, v|
        v = adjust_indentation(v)
        fmt = multi_line?(v) ?
        "%-#{width}s\n#{' '*width} <- %s\n" :
          "%-#{width}s <- %s\n"
        @output << sprintf(fmt, v, x)
      end
    end

    def adjust_indentation(string)
      string.to_s.gsub(/^/, '  ')
    end

    def multi_line?(string)
      (string.size > WRAP_WIDTH) || (string =~ /\n/)
    end

    def suggest_width(pairs)
      pairs.map { |x,v|
        max_line_length(v)
      }.select { |n| n < WRAP_WIDTH }.max || 10
    end

    def max_line_length(string)
      string.to_s.split(/\n/).map { |s| s.size }.max
    end

    def source_line
      "#{@code_file}:#{@code_line}"
    end
  end

end
