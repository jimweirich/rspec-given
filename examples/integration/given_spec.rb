require 'rspec-given'

describe "Running Givens before Whens" do
  Given(:info) { [] }
  Given { info << "outer1" }
  Given { info << "outer2" }

  context "using a when without result" do
    When { info << "when" }

    context "inner with When" do
      Given { info << "inner1" }
      Given { info << "inner2" }
      Then { info.should == ["outer1", "outer2", "inner1", "inner2", "when"] }

      context "using a nested When" do
        When { info << "when2" }
        Then { info.should == ["outer1", "outer2", "inner1", "inner2", "when", "when2"] }
      end
    end
  end

  context "using a when with a result" do
    When(:result) { info << "when" }

    context "inner with when" do
      Given { info << "inner1" }
      Given { info << "inner2" }
      Then { info.should == ["outer1", "outer2", "inner1", "inner2", "when"] }
    end
  end

  context "using no whens" do
    Given { info << "inner1" }
    Given { info << "inner2" }
    Then { info.should == ["outer1", "outer2", "inner1", "inner2"] }
  end
end

describe "Lazy Givens" do
  Given(:bomb) { fail "SHOULD NEVER BE CALLED" }

  context "when called" do
    Then { lambda { bomb }.should raise_error(StandardError, /NEVER/) }
  end

  context "when not called" do
    Given(:value) { :ok }
    Then { value.should == :ok }
  end
end

describe "Non-Lazy Givens" do
  Given(:info) { [] }

  When { info << :when }

  context "inner" do
    Given!(:a) { info << :given; "A VALUE" }
    Then { info.should == [:given, :when] }
  end

end
