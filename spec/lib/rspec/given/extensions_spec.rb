require 'spec_helper'

describe RSpec::Given::ClassExtensions do
  let(:trace) { [] }

  describe "Given with var" do
    context "with simple given" do
      Given(:a) { 1 }
      Then { a.should == 1 }
    end

    context "is lazy" do
      Given(:a) { trace << :given; 1 }
      Then { a.should == 1 }
      Then { trace.should == [] }
      Then { a; trace.should == [:given] }

      context "when nested" do
        Given(:a) { trace << :nested; 2 }
        Then { a.should == 2 }
        Then { trace.should == [] }
        Then { a; trace.should == [:nested] }
      end
    end
  end

  describe "Given without var" do
    context "is lazy" do
      Given { trace << :given }
      Then { trace.should == [:given] }

      context "when nested" do
        Given { trace << :nested }
        Then { trace.should == [:given, :nested] }
      end
    end
  end

  describe "Given!" do
    context "with simple given" do
      Given!(:a) { 1 }
      Then { a.should == 1 }
    end

    context "is not lazy" do
      Given!(:a) { trace << :given; 1 }
      Then { a.should == 1 }
      Then { trace.should == [:given] }
      Then { a; trace.should == [:given] }
    end
  end

  describe "When without result" do
    Given { trace << :given }
    When { trace << :when }
    Then { trace.should == [:given, :when] }

    context "with nesting" do
      Given { trace << :nested }
      Then { trace.should == [:given, :nested, :when] }
    end

    context "with nesting of When" do
      Given { trace << :nested }
      When { trace << :when_nested }
      Then { trace.should == [:given, :nested, :when, :when_nested] }
    end
  end

  describe "When with result" do
    Given { trace << :given }
    When(:result) { trace << :when; :result }
    Invariant { result.should == :result }

    Then { trace.should == [:given, :when] }

    context "with nesting" do
      Given { trace << :nested }
      Then { trace.should == [:given, :nested, :when] }
    end

    context "with nesting of When" do
      Given { trace << :nested }
      When { trace << :when_nested }
      Then { trace.should == [:given, :nested, :when, :when_nested] }
    end
  end

  describe "When with unreferenced result" do
    Given { trace << :given }
    When(:result) { trace << :when; :result }
    Then { trace.should == [:given, :when] }
  end

  describe "Invariant with When" do
    Given { trace << :given }
    Invariant { trace << :invariant }
    When { trace << :when }
    Then { trace.should == [:given, :when, :invariant] }
  end

  describe "Invariant without When" do
    Given { trace << :given }
    Invariant { trace << :invariant }
    Then { trace.should == [:given, :invariant] }
  end

  describe "Then" do
    Given { trace << :given }
    Then { trace << :then }
    And { trace.should == [:given, :then] }
  end

  describe "And" do
    Given { trace << :given }
    Then { trace << :then }
    And { trace << :and}
    And { trace.should == [:given, :then, :and] }
  end

  describe "inherited options" do
    context "Outer" do
      _rg_context_info[:name] = "Outer"
      _rg_context_info[:outer] = true

      Then { _rg_info(:name).should == "Outer" }
      Then { _rg_info(:outer).should == true }
      Then { _rg_info(:inner).should == nil }

      context "Inner" do
        _rg_context_info[:name] = "Inner"
        _rg_context_info[:inner] = true

        Then { _rg_info(:name).should == "Inner" }
        Then { _rg_info(:outer).should == true }
        Then { _rg_info(:inner).should == true }
      end
    end
  end

  describe "Global natural assertion configuration" do
    Given(:rspec) { false }
    Given(:nassert) { stub(:using_rspec_assertion? => rspec) }

    after do
      RSpec::Given.use_natural_assertions false
    end

    context "with no explicit word on natural assertions" do
      Then { _rg_natural_assertions?(nassert).should be_false }

      context "overridden locally" do
        use_natural_assertions
        Then { _rg_natural_assertions?(nassert).should be_true }
      end
    end

    context "with global configuration enabled" do
      When { RSpec::Given.use_natural_assertions }
      Then { _rg_natural_assertions?(nassert).should be_true }

      context "overridden locally" do
        use_natural_assertions false
        Then { _rg_natural_assertions?(nassert).should be_false }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { _rg_natural_assertions?(nassert).should be_false }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _rg_natural_assertions?(nassert).should be_true }
      end
    end

    context "with global configuration set to always" do
      When { RSpec::Given.use_natural_assertions :always }
      Then { _rg_natural_assertions?(nassert).should be_true }

      context "overridden locally" do
        use_natural_assertions false
        Then { _rg_natural_assertions?(nassert).should be_false }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { _rg_natural_assertions?(nassert).should be_true }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _rg_natural_assertions?(nassert).should be_true }
      end
    end

    context "with global configuration disabled" do
      When { RSpec::Given.use_natural_assertions false }
      Then { _rg_natural_assertions?(nassert).should be_false }

      context "overridden locally" do
        use_natural_assertions true
        Then { _rg_natural_assertions?(nassert).should be_true }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { _rg_natural_assertions?(nassert).should be_false }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _rg_natural_assertions?(nassert).should be_false }
      end
    end

  end
end
