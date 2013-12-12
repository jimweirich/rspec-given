require 'spec_helper'

describe Given::BinaryOperation do
  Given(:binary) { Given::BinaryOperation.parse(sexp) }

  context "with a valid binary sexp" do
    Given(:sexp) { [:binary,  [:@ident, "a"], :==, [:@ident, "b"]] }
    Then { expect(binary.left).to eq([:@ident, "a"]) }
    Then { expect(binary.operator).to eq(:==) }
    Then { expect(binary.right).to eq([:@ident, "b"]) }
    Then { expect(binary.explain).to eq("to equal") }
  end

  context "with a valid binary sexp using ===" do
    Given(:sexp) { [:binary,  [:@ident, "a"], :===, [:@ident, "b"]] }
    Then { expect(binary.left).to eq([:@ident, "a"]) }
    Then { expect(binary.operator).to eq(:===) }
    Then { expect(binary.right).to eq([:@ident, "b"]) }
    Then { expect(binary.explain).to eq("to be matched by") }
  end

  context "with a non-binary sexp" do
    Given(:sexp) { [:something_else] }
    Then { expect(binary).to be_nil }
  end

end
