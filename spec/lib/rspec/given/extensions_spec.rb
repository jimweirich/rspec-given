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
end
