require 'example_helper'

describe "Running Givens before Whens" do
  Given(:info) { [] }
  Given { info << "outer1" }
  Given { info << "outer2" }

  context "using a when without result" do
    When { info << "when" }

    context "inner with When" do
      Given { info << "inner1" }
      Given { info << "inner2" }
      Then { given_assert_equal ["outer1", "outer2", "inner1", "inner2", "when"], info }

      context "using a nested When" do
        When { info << "when2" }
        Then { given_assert_equal ["outer1", "outer2", "inner1", "inner2", "when", "when2"], info}
      end

      context "using two nested When" do
        When { info << "when2a" }
        When { info << "when2b" }
        Then {
          given_assert_equal ["outer1", "outer2", "inner1", "inner2", "when", "when2a", "when2b"], info
        }
      end
    end
  end

  context "using a when with a result" do
    When(:result) { info << "when" }

    context "inner with when" do
      Given { info << "inner1" }
      Given { info << "inner2" }
      Then { given_assert_equal ["outer1", "outer2", "inner1", "inner2", "when"], info }
    end
  end

  context "using no whens" do
    Given { info << "inner1" }
    Given { info << "inner2" }
    Then { given_assert_equal ["outer1", "outer2", "inner1", "inner2"], info }
  end
end

describe "Lazy Givens" do
  Given(:bomb) { fail StandardError, "SHOULD NEVER BE CALLED" }

  context "when called" do
    Then {
      given_assert_raises(StandardError, /NEVER/) { bomb }
    }
  end

  context "when not called" do
    Given(:value) { :ok }
    Then { given_assert_equal :ok, value }
  end
end

describe "Non-Lazy Givens" do
  Given(:info) { [] }

  When { info << :when }

  context "inner" do
    Given!(:a) { info << :given; "A VALUE" }
    Then { given_assert_equal [:given, :when], info }
  end

end
