require 'spec_helper'

describe "#have_failed" do
  CustomError = Class.new(StandardError)
  DifferentError = Class.new(StandardError)
  ExpectationError = RSpec::Expectations::ExpectationNotMetError

  context "with a failure" do
    When(:result) { fail CustomError, "Ouch" }

    Then { result.should raise_error(CustomError, "Ouch") }
    Then { result.should have_failed(CustomError, "Ouch") }
    Then { result.should have_raised(CustomError, "Ouch") }

    Then { lambda { result.should be_nil }.should raise_error(CustomError, "Ouch") }
    Then { lambda { result.should == 0 }.should raise_error(CustomError, "Ouch") }
    Then { lambda { result.should_not == 0 }.should raise_error(CustomError, "Ouch") }

    Then { lambda { result.should_not have_failed }.should raise_error(ExpectationError) }
  end

  context "with a standard failure" do
    When(:result) { fail "Ouch" }

    Then { result.should raise_error(StandardError, "Ouch") }
  end

  context "with a different failure" do
    When(:result) { fail CustomError, "Ouch" }
    Then { result.should_not have_failed(DifferentError) }
    Then { lambda { result.should have_failed(DifferentError) }.should raise_error(ExpectationError) }
  end

  context "with a non-failure" do
    When(:result) { :ok }
    Then { result.should_not have_failed }
    Then { lambda { result.should have_failed }.should raise_error(RSpec::Expectations::ExpectationNotMetError) }
  end
end
