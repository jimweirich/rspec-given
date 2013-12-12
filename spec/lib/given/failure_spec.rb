require 'spec_helper'
require 'given/failure'

describe Given::Failure do
  Given(:other_error) { Class.new(StandardError) }
  Given(:custom_error) { Class.new(StandardError) }

  Given(:exception) { StandardError.new("Oops") }
  Given(:failure) { Given::Failure.new(exception) }

  Then { expect(failure.is_a?(Given::Failure)).to eq(true) }

  describe "general operations" do
    Then { expect { failure.to_s }.to raise_error(StandardError, "Oops") }
    Then { expect { failure.call }.to raise_error(StandardError, "Oops") }
    Then { expect { failure.nil? }.to raise_error(StandardError, "Oops") }
    Then { expect { failure == 0 }.to raise_error(StandardError, "Oops") }
    Then { expect { failure != 0 }.to raise_error(StandardError, "Oops") }
    Then { expect { failure =~ 0 }.to raise_error(StandardError, "Oops") }
    Then { expect { ! failure }.to raise_error(StandardError, "Oops") }
  end

  describe "raising error" do
    Then { expect(failure).to raise_error(StandardError, "Oops") }
    Then { expect(failure).to raise_error(StandardError) }
    Then { expect(failure).to raise_error }
  end

  describe "== have_failed" do
    use_natural_assertions_if_supported
    Then { failure == have_failed(StandardError, "Oops") }
    Then { failure == have_failed(StandardError) }
    Then { failure == have_failed }
  end

  describe "== Failure" do
    use_natural_assertions_if_supported
    Then { failure == Failure(StandardError, "Oops") }
    Then { failure == Failure(StandardError) }
    Then { failure == Failure() }
  end

  describe "!= Failure" do
    use_natural_assertions_if_supported
    Then { expect { failure != Object.new }.to raise_error(StandardError) }
    Then { failure != Failure(other_error) }
  end

end
