require 'rspec/given'
require 'spec_helper'
require 'flexmock/rspec'

describe "And" do
  Given(:info) { [] }
  Given(:mock) { flexmock("mock") }

  describe "And is called after Then" do
    Given { mock.should_receive(:and_ran).once }
    Then { info << "T" }
    And {
      info.should == ["T"]
      mock.and_ran
    }
  end

  describe "And is called only once with multiple Thens" do
    Then { info << "T" }
    Then { info << "T2" }
    And { info.should == ["T"] }
  end

  describe "Inherited Ands are not run" do
    Then { info << "T-OUTER" }
    And { info << "A-OUTER" }
    And { info.should == ["T-OUTER", "A-OUTER"] }

    context "inner" do
      Then { info << "T-INNER" }
      And { info << "A-INNER" }
      And { info.should == ["T-INNER", "A-INNER"] }
    end
  end

  describe "Ands require a Then" do
    begin
      And { }
    rescue StandardError => ex
      @message = ex.message
    end

    it "should define a message" do
      message = self.class.instance_eval { @message }
      message.should =~ /and.*without.*then/i
    end
  end

end
