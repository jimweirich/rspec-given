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

    Then { expect { result.should be_nil }.to raise_error(CustomError, "Ouch") }
    Then { expect { result.should == 0 }.to raise_error(CustomError, "Ouch") }
    Then { expect { result.should_not == 0 }.to raise_error(CustomError, "Ouch") }

    Then { expect { result.should_not have_failed }.to raise_error(ExpectationError) }
  end

  context "with a standard failure" do
    When(:result) { fail "Ouch" }

    Then { result.should raise_error(StandardError, "Ouch") }
    Then { result.should raise_error(StandardError, /^O/) }
    Then { result.should raise_error(StandardError) }
    Then { result.should raise_error }

    Then { result.should have_failed(StandardError, "Ouch") }
    Then { result.should have_failed(StandardError, /^O/) }
    Then { result.should have_failed(StandardError) }
    Then { result.should have_failed }
  end

  context "with a different failure" do
    When(:result) { fail CustomError, "Ouch" }
    Then { result.should_not have_failed(DifferentError) }
    Then { expect { result.should have_failed(DifferentError) }.to raise_error(ExpectationError) }
  end

  context "with a pending exception" do
    When(:result) { fail RSpec::Core::Pending::PendingDeclaredInExample, "Required pending ... please ignore" }
    Then { ::RSpec::Expectations.fail_with "This spec should have been pending" }
  end

  context "with a non-failure" do
    When(:result) { :ok }
    Then { result.should_not have_failed }
    Then { expect { result.should have_failed }.to raise_error(RSpec::Expectations::ExpectationNotMetError) }
  end

  context "with natural assertions" do
    use_natural_assertions

    context "with failure" do
      When(:result) { fail CustomError, "Ouch" }
      Then { result == have_failed(CustomError, "Ouch") }
      Then { ! (result != have_failed(CustomError, "Ouch")) }
      Then { expect { result == :something }.to raise_error(CustomError, "Ouch") }
    end

    context "with different failure" do
      When(:result) { fail DifferentError, "Ouch" }
      Then { ! (result == have_failed(CustomError, "Ouch")) }
      Then { result != have_failed(CustomError, "Ouch") }
    end

  end
end
