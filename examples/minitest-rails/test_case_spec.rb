require 'minitest/autorun'
require 'active_support_helper'
require 'minitest/given'
require 'example_helper'


describe ActiveSupport::TestCase, :model do
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
        Then { given_assert_equal ["outer1", "outer2", "inner1", "inner2", "when", "when2a", "when2b"], info }
      end
    end
  end
end

