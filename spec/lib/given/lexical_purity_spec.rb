require 'spec_helper'

LEXICAL_PURITY_GLOBAL_CONSTANT = 3

describe "Lexical Purity" do
  use_natural_assertions_if_supported

  A = 1
  Given(:avalue) { 1 }
  context "nested" do
    B = 2
    Given(:bvalue) { 2 }
    Then { A == 1 }
    Then { avalue == 1 }
    Then { B == 2 }
    Then { bvalue == 2 }
    Then { LEXICAL_PURITY_GLOBAL_CONSTANT == 3 }
  end
end
