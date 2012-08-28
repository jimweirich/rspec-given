require 'spec_helper'

describe "#have_failed" do
  class CustomError < StandardError; end
  When(:result) { fail CustomError, "Ouch" }

  Then { result.should raise_error(CustomError, "Ouch") }
  Then { result.should have_failed(CustomError, "Ouch") }

  Then { lambda { result.should be_nil }.should raise_error(CustomError, "Ouch") }
  Then { lambda { result.should == 0 }.should raise_error(CustomError, "Ouch") }
  Then { lambda { result.should_not == 0 }.should raise_error(CustomError, "Ouch") }
end
