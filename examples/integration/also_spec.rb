require 'rspec/given'
require 'spec_helper'

describe "Also" do
  Given(:info) { [] }
  Given(:mock) { flexmock("mock") }

  describe "Also is called after Then" do
    Given { mock.should_receive(:also_ran).once }
    Then { info << "T" }
    Also {
      info.should == ["T"]
      mock.also_ran
    }
  end

  describe "Also is called only once with multiple Thens" do
    Then { info << "T" }
    Then { info << "T2" }
    Also { info.should == ["T"] }
  end

  describe "Inherited Alsos are not run" do
    Then { info << "T-OUTER" }
    Also { info << "A-OUTER" }
    Also { info.should == ["T-OUTER", "A-OUTER"] }

    context "inner" do
      Then { info << "T-INNER" }
      Also { info << "A-INNER" }
      Also { info.should == ["T-INNER", "A-INNER"] }
    end
  end

  describe "Alsos require a Then" do
    begin
      Also { }
    rescue StandardError => ex
      @message = ex.message
    end

    it "should define a message" do
      message = self.class.instance_eval { @message }
      message.should =~ /also.*without.*then/i
    end
  end

end
