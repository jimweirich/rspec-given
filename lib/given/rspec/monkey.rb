require 'rspec'
require 'rspec/expectations'
require 'given/module_methods'

# Monkey patch RSpec to detect matchers used in expectations.

unless defined?(RSpec::Given::MONKEY)

  if defined?(RSpec::Expectations::PositiveExpectationHandler) &&
      defined?(RSpec::Expectations::NegativeExpectationHandler)

    RSpec::Given::MONKEY = true

    module RSpec
      module Expectations
        class PositiveExpectationHandler
          class << self
            alias _gvn_rspec_original_handle_matcher handle_matcher
            def handle_matcher(actual, matcher, message=nil, &block)
              ::Given.framework.explicitly_asserted
              _gvn_rspec_original_handle_matcher(actual, matcher, message, &block)
            end
          end
        end

        class NegativeExpectationHandler
          class << self
            alias _gvn_rspec_original_handle_matcher handle_matcher
            def handle_matcher(actual, matcher, message=nil, &block)
              ::Given.framework.explicitly_asserted
              _gvn_rspec_original_handle_matcher(actual, matcher, message, &block)
            end
          end
        end
      end
    end

  else
    RSpec::Given::MONKEY = false
  end

end
