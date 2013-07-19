require 'spec_helper'

describe Given::BinaryOperation do
  Given(:binary) { Given::BinaryOperation.parse(sexp) }

  context "with a valid binary sexp" do
    Given(:sexp) { [:binary,  [:@ident, "a"], :==, [:@ident, "b"]] }
    Then { binary.left.should == [:@ident, "a"] }
    Then { binary.operator.should == :== }
    Then { binary.right.should == [:@ident, "b"] }
    Then { binary.explain.should == "to equal" }
  end

  context "with a valid binary sexp using ===" do
    Given(:sexp) { [:binary,  [:@ident, "a"], :===, [:@ident, "b"]] }
    Then { binary.left.should == [:@ident, "a"] }
    Then { binary.operator.should == :=== }
    Then { binary.right.should == [:@ident, "b"] }
    Then { binary.explain.should == "to be matched by" }
  end

  context "with a non-binary sexp" do
    Given(:sexp) { [:something_else] }
    Then { binary.should be_nil }
  end

end
