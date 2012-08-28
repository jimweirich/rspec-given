require 'rspec/given'

describe "Invariants" do
  Given(:info) { [] }

  Invariant { info << "I1" }

  Then { info.should == ["I1"] }

  context "with nested invariants" do
    Invariant { info << "I2" }

    Then { info.should == ["I1", "I2"] }
  end

  context "with multiple invariants" do
    Invariant { info << "I2a" }
    Invariant { info << "I2b" }

    Then { info.should == ["I1", "I2a", "I2b"] }
  end

  context "with a when" do
    Invariant { info << "I2" }

    When(:when_info) { info.dup }

    Then { info.should == ["I1", "I2"] }
    Then { when_info.should == [] }
  end
end
