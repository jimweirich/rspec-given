require 'spec_helper'

describe "Environmental Access" do
  use_natural_assertions false
  X = 1
  Given(:a) { 2 }
  FauxThen { X + a }

  Then { block_result.should == 3 }
  Then { ev.eval_string("X").should == "1" }
  Then { ev.eval_string("a").should == "2" }
  Then { ev.eval_string("X+a").should == "3" }
end

module Nested
  X = 1
  describe "Environmental Access with Nested modules" do
    use_natural_assertions false
    Given(:a) { 2 }
    FauxThen { X + a }
    Then { block_result.should == 3 }
    Then { ev.eval_string("a").should == "2" }
    Then { ev.eval_string("X").should == "1" }
    Then { ev.eval_string("a+X").should == "3" }
  end
end

describe "Evaluator with error object" do
  use_natural_assertions false
  FauxThen { 1 }
  When(:result) { ev.eval_string("fail 'XYZ'") }
  Then { result.class.should == Given::EvalErr }
  Then { result.inspect.should == "RuntimeError: XYZ" }
end
