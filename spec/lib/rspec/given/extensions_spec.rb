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

    context "when preceeded by a Given block" do
      Given { trace << :given }
      Given!(:other) { trace << :given_bang }
      Then { trace.should == [:given, :given_bang] }
    end
  end

  describe "Given/Given!/before ordering" do
    before { trace << :before_outer }
    Given { trace << :given_outer }
    Given!(:x_outer) { trace << :given_bang_outer }
    before { trace << :before2_outer }
    When { trace << :when_outer }
    When(:result_outer) { trace << :when_result_outer }

    Then {
      trace.should == [
        :before_outer, :before2_outer,
        :given_outer, :given_bang_outer,
        :when_outer,
        :when_result_outer,
      ]
    }

    context "with a nested When" do
      before { trace << :before_inner }
      Given { trace << :given_inner }
      Given!(:x_inner) { trace << :given_bang_inner }
      When(:result_inner) { trace << :when_result_inner }
      When { trace << :when_inner }

      Then {
        trace.should == [
          :before_outer, :before2_outer,
          :given_outer, :given_bang_outer,
          :given_inner, :given_bang_inner,
          :when_outer, :when_result_outer,
          :before_inner,
          :when_result_inner, :when_inner,
        ]
      }
    end

    context "without a nested When" do
      before { trace << :before_inner }
      Given { trace << :given_inner }
      Given!(:x_inner) { trace << :given_bang_inner }

      Then {
        trace.should == [
          :before_outer, :before2_outer,
          :given_outer, :given_bang_outer,
          :given_inner, :given_bang_inner,
          :when_outer, :when_result_outer,
          :before_inner,
        ]
      }
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

  describe "Then referencing givens" do
    Given(:given_value) { :ok }
    Then { given_value == :ok }
  end

  describe "Then referencing when results" do
    When(:result) { :ok }
    Then { result == :ok }
  end

  describe "And" do
    Given { trace << :given }
    Then { trace << :then }
    And { trace << :and}
    And { trace.should == [:given, :then, :and] }
  end

end

describe "use_natural_assertions" do
  context "when in JRuby" do
    CONTEXT = self

    When(:result) { CONTEXT.use_natural_assertions }

    if RSpec::Given::NATURAL_ASSERTIONS_SUPPORTED
      Then { result.should_not have_failed }
    else
      Then { result.should have_failed(ArgumentError) }
    end
  end
end
