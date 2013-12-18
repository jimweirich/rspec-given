
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

  class Evaluator
    def initialize(example, block)
      @example = example
      @block = block
    end

    def eval_string(exp_string)
      limit_length(eval_in_context(exp_string).inspect)
    rescue StandardError => ex
      EvalErr.new("#{ex.class}: #{ex.message}")
    end

    def location
      Given.location_of(@block)
    end

    private

    MAX_INSPECT_SIZE = 2000

    def limit_length(string)
      if string.size > MAX_INSPECT_SIZE
        string[0..MAX_INSPECT_SIZE] + " (...truncated...)"
      else
        string
      end
    end

    def eval_in_context(exp_string)
      exp_proc = "proc { #{exp_string} }"
      blk = eval(exp_proc, @block.binding)
      @example.instance_eval(&blk)
    end
  end
end
