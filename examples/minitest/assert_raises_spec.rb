require 'minitest/given'
require 'minitest/autorun'

describe "stacks" do
  context "when it fails" do
    When(:result) { fail StandardError, "Oops" }

    Then { result.must_raise(StandardError, /oops/i) }
    Then {
      assert_raises(StandardError, /oops/i) do
        result.die
      end
    }
    Then { result == Failure() }
    Then { result == Failure(StandardError) }
  end

  context "when it does not fail" do
    When(:result) { :ok }

    Then { result != Failure() }
    Then { result != Failure(StandardError) }
  end

end
