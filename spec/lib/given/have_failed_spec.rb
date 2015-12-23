require 'spec_helper'

module HaveFailedSpec
  CustomError = Class.new(StandardError)
  DifferentError = Class.new(StandardError)
  ExpectationError = RSpec::Expectations::ExpectationNotMetError

  describe "#have_failed" do
    context "with a failure" do
      When(:result) { fail CustomError, "Ouch" }

      Then { expect { result.call }.to raise_error(CustomError, "Ouch") }
      Then { expect(result).to have_failed(CustomError, "Ouch") }
      Then { expect(result).to have_raised(CustomError, "Ouch") }

      Then { expect { expect(result).to be_nil }.to raise_error(CustomError, "Ouch") }
      Then { expect { expect(result).to eq(0) }.to raise_error(CustomError, "Ouch") }
      Then { expect { expect(result).to_not eq(0) }.to raise_error(CustomError, "Ouch") }

      Then { expect { expect(result).to_not have_failed }.to raise_error(ExpectationError) }
    end

    context "with a standard failure" do
      When(:result) { fail "Ouch" }

      Then { expect { result.call }.to raise_error(StandardError, "Ouch") }
      Then { expect { result.call }.to raise_error(StandardError, /^O/) }
      Then { expect { result.call }.to raise_error(StandardError) }
      Then { expect { result.call }.to raise_error }

      Then { expect(result).to have_failed(StandardError, "Ouch") }
      Then { expect(result).to have_failed(StandardError, /^O/) }
      Then { expect(result).to have_failed(StandardError) }
      Then { expect(result).to have_failed }
    end

    context "with a different failure" do
      When(:result) { fail CustomError, "Ouch" }
      Then { expect { expect(result).to have_failed(DifferentError) }.to raise_error(ExpectationError) }
    end

    context "with a skip exception" do
      # `skip` replaces old `pending` behavior in RSpec < 3
      #  Details: http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3
      def skip_error
        RSpec::Given::Framework.new.pending_error
      end
      When(:result) { fail skip_error, "Used `skip` in example ... please ignore" }
      Then { Given.fail_with "This example should have been skipped" }
    end

    context "with a pending invocation" do
      When(:result) { pending "Forcing a pending in example ... please ignore" }
      Then { Given.fail_with "This example should have been regarded as pending" }
    end

    context "with a non-failure" do
      When(:result) { :ok }
      Then { expect(result).to_not have_failed }
      Then { expect { expect(result).to have_failed }.to raise_error(RSpec::Expectations::ExpectationNotMetError) }
    end

    context "with natural assertions" do

      context "with failure" do
        When(:result) { fail CustomError, "Ouch" }
        Then { result == have_failed(CustomError, "Ouch") }
        Then { ! (result != have_failed) }
        Then { expect { result == :something }.to raise_error(CustomError, "Ouch") }
      end

      context "with different failure" do
        When(:result) { fail DifferentError, "Ouch" }
        Then { ! (result == have_failed(CustomError, "Ouch")) }
      end

    end
  end
end
