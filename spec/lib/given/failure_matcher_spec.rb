require 'spec_helper'
require 'given/failure_matcher'

module FailureMatcherSpec
  OtherError  = Class.new(StandardError)
  CustomError = Class.new(StandardError)
  SubError    = Class.new(CustomError)
  NotMetError = RSpec::Expectations::ExpectationNotMetError

  describe Given::FailureMatcher do
    use_natural_assertions_if_supported

    Given(:error) { CustomError.new("CUSTOM") }

    Given(:failure_result) { Given::Failure.new(error) }

    context "with matching failure results" do
      Then { Failure(CustomError, "CUSTOM").matches?(failure_result) }
      Then { Failure(CustomError, /CUSTOM/).matches?(failure_result) }
      Then { Failure(CustomError).matches?(failure_result) }
      Then { Failure(StandardError).matches?(failure_result) }
      Then { Failure().matches?(failure_result) }
    end

    context "with non-matching results" do
      Then {
        expect {
          Failure(StandardError).matches?(Object.new)
        }.to raise_error(NotMetError,
          /Expected.*StandardError, but nothing failed/)
      }

      Then {
        expect {
          Failure(StandardError, /CUSTOM/).matches?(Object.new)
        }.to raise_error(NotMetError,
          /Expected.*StandardError.*matching.*CUSTOM.*, but nothing failed/)
      }

      Then {
        expect {
          Failure(StandardError, /OTHER/).matches?(failure_result)
        }.to raise_error(NotMetError,
          /Expected.*StandardError matching.*OTHER.*, but got.*CustomError.*CUSTOM/)
      }

      Then {
        expect {
          Failure(OtherError, /CUSTOM/).matches?(failure_result)
        }.to raise_error(NotMetError,
          /Expected.*OtherError matching.*CUSTOM.*, but got.*CustomError.*CUSTOM/)
      }

      Then {
        expect {
          Failure(SubError, /CUSTOM/).matches?(failure_result)
        }.to raise_error(NotMetError,
          /Expected.*SubError matching.*CUSTOM.*, but got.*CustomError.*CUSTOM/)
      }

      Then {
        expect {
          Failure(OtherError).matches?(failure_result)
        }.to raise_error(NotMetError,
          /Expected.*OtherError, but got.*CustomError.*CUSTOM/)
      }
    end

    describe "==" do
      Then { failure_result       == Failure() }
      Then { failure_result       == Failure(CustomError) }
      Then { Failure()            == failure_result }
      Then { Failure(CustomError) == failure_result }
    end

    describe "!=" do
      Then { failure_result != Failure(SubError) }
      Then { Failure(SubError) != failure_result }
      Then { Failure() != nil }
      Then { nil != Failure() }
    end
  end
end
