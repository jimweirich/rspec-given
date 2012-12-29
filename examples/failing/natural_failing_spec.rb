require 'rspec/given'
require 'rspec/given/natural_assertion'

describe "Natural Assertions" do
  Given(:foo) { 1 }
  Given(:expected) { 2 }
  Given(:ary) { [1] }
  Given(:empty) { [] }
  Given(:null) { nil }
  Then { foo+foo+2*foo == expected }
  Then { nil == "HI" && true && :symbol  && 1}
  Then { foo.should == 2 }
  Then { foo != 1 }
  Then { foo.should_not == 1 }
  Then { foo.should_not be_nil }
  Then { ary.empty? }
  Then { true }
  And  { !null.nil? }
  Then { fail "OUCH" }
  Then { ! empty.empty? }
  Then {
    (puts "Ha ha world", ! true)
  }

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
