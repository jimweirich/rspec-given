# -*- coding: utf-8 -*-

module Given
  module Ext
    module Numeric

      def ±(del=nil)
        result = Given::Fuzzy::FuzzyNumber.new(self)
        result.delta(del) if del
        result
      end

      def ‰(percentage=nil)
        result = Given::Fuzzy::FuzzyNumber.new(self)
        result.percent(percentage) if percentage
        result
      end

      def €(neps=nil)
        result = Given::Fuzzy::FuzzyNumber.new(self)
        result.epsilon(neps) if neps
        result
      end

    end
  end
end

class Numeric
  include Given::Ext::Numeric
end
