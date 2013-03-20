require 'rspec/given'

module ContextMethods
  def use_natural_assertions_if_supported(enabled=true)
    if enabled && ! RSpec::Given::NATURAL_ASSERTIONS_SUPPORTED
      Given {
        pending "Natural assertions are not supported in JRuby"
      }
    else
      use_natural_assertions(enabled)
    end
  end
end

RSpec.configure do |c|
  c.extend(ContextMethods)
end


# The Faux module defines a FauxThen that is used to setup an
# environment identical to the real Then blocks in order to setup a
# realistic NaturalAssertion object that can be used for making
# assertions.
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
# * result_block -- is the result of evaluating the FauxThen block
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
    def block_result
      instance_eval(&self.class.the_block)
    end

    def na
      block = self.class.the_block
      RSpec::Given::NaturalAssertion.new("FauxThen", block, self, self.class._rgc_lines)
    end
  end
end

# Extend RSpec with our Faux Then blocks
RSpec.configure do |c|
  c.extend(Faux::CX)
  c.include(Faux::IX)
end
