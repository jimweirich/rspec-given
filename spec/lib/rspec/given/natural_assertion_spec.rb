require 'rspec/given'

describe RSpec::Given::NaturalAssertion do
  Given(:bind) {
    a = 1
    binding
  }
  Given(:lines) { RSpec::Given::LineExtractor.new }
  Given(:nassert) { RSpec::Given::NaturalAssertion.new(block, bind, lines) }

  describe "detecting should" do
    context "with should" do
      Given(:block) {
        lambda { a.should == 1 }
      }
      Then { nassert.should be_using_should }
    end

    context "with should in multi-line block" do
      Given(:block) {
        lambda {
          a.should == 1
        }
      }
      Then { nassert.should be_using_should }
    end

    context "with should_not" do
      Given(:block) {
        lambda { a.should_not == 1 }
      }
      Then { nassert.should be_using_should }
    end

    context "with natural assertion" do
      Given(:block) {
        lambda { a == 1 }
      }
      Then { nassert.should_not be_using_should }
    end
  end

  describe "failure messages" do
    context "with equals assertion" do
      Given(:msg) { nassert.message }
      Given(:block) {
        lambda { a == 2 }
      }
      Then { msg.should =~ /^Then expression/ }
      Then { msg.should =~ /expected: +2/ }
      Then { msg.should =~ /got: +1/ }
      Then { msg.should =~ /false +<- +a == 2/ }
      Then { msg.should =~ /1 +<- +a/ }
    end

    context "with not-equals assertion" do
      Given(:msg) { nassert.message }
      Given(:block) {
        lambda { a != 1 }
      }
      Then { msg.should =~ /^Then expression/ }
      Then { msg.should =~ /expected not: +1/ }
      Then { msg.should =~ /got: +1/ }
      Then { msg.should =~ /false +<- +a != 1/ }
      Then { msg.should =~ /1 +<- +a/ }
    end
  end
end
