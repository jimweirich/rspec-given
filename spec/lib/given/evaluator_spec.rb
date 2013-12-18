require 'spec_helper'

describe "Environmental Access" do
  use_natural_assertions false
  X = 1
  Given(:a) { 2 }
  FauxThen { X + a }

  Then { expect(block_result).to eq(3) }
  Then { expect(ev.eval_string("X")).to eq("1") }
  Then { expect(ev.eval_string("a")).to eq("2") }
  Then { expect(ev.eval_string("X+a")).to eq("3") }
end

module Nested
  X = 1
  describe "Environmental Access with Nested modules" do
    use_natural_assertions false
    Given(:a) { 2 }
    FauxThen { X + a }
    Then { expect(block_result).to eq(3) }
    Then { expect(ev.eval_string("a")).to eq("2") }
    Then { expect(ev.eval_string("X")).to eq("1") }
    Then { expect(ev.eval_string("a+X")).to eq("3") }
  end
end

describe "Evaluator with error object" do
  use_natural_assertions false
  FauxThen { 1 }
  When(:result) { ev.eval_string("fail 'XYZ'") }
  Then { expect(result.class).to eq(Given::EvalErr) }
  Then { expect(result.inspect).to eq("RuntimeError: XYZ") }
end

describe "Evaluator with long inspect string" do
  use_natural_assertions false
  Given(:long) { "X" * 3000 }
  FauxThen { long }
  Then { expect(ev.eval_string("long")).to eq(%{"#{long[0...2000]} (...truncated...)}) }
end
