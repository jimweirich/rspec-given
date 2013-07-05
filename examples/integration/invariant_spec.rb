require 'example_helper'

describe "Invariants" do
  Given(:info) { [] }

  Invariant { info << "I1" }

  Then { given_assert_equal ["I1"], info }

  context "with nested invariants" do
    Invariant { info << "I2" }

    Then { given_assert_equal ["I1", "I2"], info }
  end

  context "with multiple invariants" do
    Invariant { info << "I2a" }
    Invariant { info << "I2b" }

    Then { given_assert_equal ["I1", "I2a", "I2b"], info }
  end

  context "with a when" do
    Invariant { info << "I2" }

    When(:when_info) { info.dup }

    Then { given_assert_equal ["I1", "I2"], info }
    Then { given_assert_equal [], when_info }
  end
end
