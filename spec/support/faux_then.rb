

# The Faux module defines a FauxThen method that is used to setup an
# environment identical to the real Then blocks. This makes it easy to
# create realistic NaturalAssertion and Evaluator objects that can be
# used for making assertions.
#
# Typical Usage:
#
#     context "with something" do
#       Given(:a) { 1 }
#       FauxThen { a + 2 }
#       Then { result_block == 3 }
#       Then { na.evaluate("a") == 1 }
#     end
#
# The FauxThen sets up two special values:
#
# * block_result -- is the result of evaluating the FauxThen block
# * na -- is a the natural assertion object whose context is the
#         FauxThen block.
#
module Faux
  module CX
    def FauxThen(&block)
      @block = block
    end
    def the_block
      @block
    end
  end

  module IX
    def faux_block
      self.class.the_block
    end

    def block_result
      instance_eval(&self.class.the_block)
    end

    def na
      block = self.class.the_block
      Given::NaturalAssertion.new("FauxThen", block, self, self.class._Gvn_lines)
    end

    def ev
      Given::Evaluator.new(self, self.class.the_block)
    end
  end
end

# Extend RSpec with our Faux Then blocks
RSpec.configure do |c|
  c.extend(Faux::CX)
  c.include(Faux::IX)
end
