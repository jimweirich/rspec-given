require 'rspec/given'

# These extensions are used for framework testing, where failing a
# Then block is a passing condition.
module Given
  module InstanceExtensions
    NotMetError = RSpec::Expectations::ExpectationNotMetError

    def _gvn_fail(&block)
      expect { _gvn_then(&block) }.to raise_error(NotMetError)
    end

    def _gvn_error(&block)
      expect { _gvn_then(&block) }.to raise_error(StandardError)
    end
  end

  module ClassExtensions

    # Fails spec if block passes.
    def FAIL(&block)
      Then(on_eval: "_gvn_fail", &block)
    end

    # Fails spec if block does not raise some kind of error.
    def ERROR(&block)
      Then(on_eval: "_gvn_error", &block)
    end

  end
end
