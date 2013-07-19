module Given

  class BinaryOperation
    BINARY_EXPLAINATIONS = {
      :==  => "to equal",
      :!=  => "to not equal",
      :<   => "to be less than",
      :<=  => "to be less or equal to",
      :>   => "to be greater than",
      :>=  => "to be greater or equal to",
      :=~  => "to match",
      :!~  => "to not match",
      :=== => "to be matched by",
    }

    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    def explain
      BINARY_EXPLAINATIONS[operator]
    end

    def self.parse(sexp)
      return nil unless sexp.first == :binary
      new(sexp[1], sexp[2], sexp[3])
    end
  end

end
