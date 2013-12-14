require 'rspec/given'

describe "Natural Assertions" do
  use_natural_assertions

  Given(:foo) { 1 }
  Given(:expected) { 2 }
  Given(:ary) { [1] }
  Given(:empty) { [] }
  Given(:null) { nil }
  Then { foo+foo+2*foo == expected }
  Then { nil == "HI" && true && :symbol  && 1}
  Then { expect(foo).to eq(2) }
  Then { foo != 1 }
  Then { expect(foo).to_not == 1 }
  Then { expect(foo).to be_nil }
  Then { ary.empty? }
  Then { !null.nil? }
  Then { fail "OUCH" }
  Then { ! empty.empty? }
  Then {
    (puts "Ha ha world", ! true)
  }

  Then { Math.sqrt(10) == about(3.1623).percent(0.0001) }

  describe "Error Examples" do
    When(:result) { fail "OUCH" }
    Then { result == :ok }
  end

  describe "Non-Error Failures" do
    When(:result) { :ok }
    Then { result == have_failed(StandardError, /^O/) }
  end

  context "Incorrect non-idempotent conditions" do
    Given(:ary) { [1, 2, 3] }
    Then { ary.delete(1) == nil }
  end

  context "Correct idempotent conditions" do
    Given(:ary) { [1, 2, 3] }
    When(:result) { ary.delete(1) }
    Then { result == nil }
  end
end
