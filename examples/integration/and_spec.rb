require 'example_helper'

describe "And" do

  Given(:info) { [] }

  describe "And is called after Then" do
    Then { info << "T" }
    And { info << "A" }
    And { given_assert_equal ["T", "A"], info }
  end

  describe "And is called only once with multiple Thens" do
    Then { info << "T" }
    Then { info << "T2" }
    And { given_assert(info == ["T"] || info == ["T2"]) }
  end

  describe "Inherited Ands are not run" do
    Then { info << "T-OUTER" }
    And { info << "A-OUTER" }
    And { given_assert_equal ["T-OUTER", "A-OUTER"], info }

    context "inner" do
      Then { info << "T-INNER" }
      And { info << "A-INNER" }
      And { given_assert_equal ["T-INNER", "A-INNER"], info }
    end
  end

  describe "Ands require a Then" do
    begin
      And { }
    rescue StandardError => ex
      @message = ex.message
    end

    it "defines a message" do
      message = self.class.instance_eval { @message }
      given_assert_match(/and.*without.*then/i, message)
    end
  end

end
