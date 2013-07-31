require 'spec_helper'
require 'rspec/given'
require 'given/assertions'

describe Given::Assertions do
  use_natural_assertions_if_supported

  Given { extend Given::Assertions }

  describe "Assert { }" do
    Given { Given::Assertions.enable_asserts }

    context "with true assertion" do
      When(:result) { Assert { true } }
      Then { result != Failure() }
    end

    context "with false assertion" do
      When(:result) {
        Assert { false }
      }
      Then { result == Failure(Given::Assertions::AssertError, /Assert.*false/) }
    end

    context "when disabled" do
      Given { Given::Assertions.enable_asserts false }
      When(:result) { Assert { false } }
      Then { result != Failure() }
    end
  end

  describe "Precondition { }" do
    Given { Given::Assertions.enable_preconditions }

    context "with true assertion" do
      When(:result) { Precondition { true } }
      Then { result != Failure() }
    end

    context "with false assertion" do
      When(:result) {
        Precondition { false }
      }
      Then { result == Failure(Given::Assertions::PreconditionError, /Precondition.*false/) }
    end

    context "when disabled" do
      Given { Given::Assertions.enable_preconditions false }
      When(:result) { Precondition { false } }
      Then { result != Failure() }
    end
  end

  describe "Postcondition { }" do
    Given { Given::Assertions.enable_preconditions }

    context "with true assertion" do
      When(:result) { Postcondition { true } }
      Then { result != Failure() }
    end

    context "with false assertion" do
      When(:result) {
        Postcondition { false }
      }
      Then { result == Failure(Given::Assertions::PostconditionError, /Postcondition.*false/) }
    end

    context "when disabled" do
      Given { Given::Assertions.enable_preconditions false }
      When(:result) { Postcondition { false } }
      Then { result != Failure() }
    end
  end
end
