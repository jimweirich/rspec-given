require 'rspec'
require 'rspec/given/module_methods'

# Monkey patch RSpec to detect matchers used in expectations.

unless defined?(RSpec::Given::MONKEY)

  if defined?(RSpec::Expectations::PositiveExpectationHandler) &&
      defined?(RSpec::Expectations::NegativeExpectationHandler)

    RSpec::Given::MONKEY = true

    module RSpec
      module Expectations
        class PositiveExpectationHandler
          class << self
            alias _rg_rspec_original_handle_matcher handle_matcher
            def handle_matcher(actual, matcher, message=nil, &block)
              RSpec::Given.matcher_called = true
              _rg_rspec_original_handle_matcher(actual, matcher, message, &block)
            end
          end
        end

        class NegativeExpectationHandler
          class << self
            alias _rg_rspec_original_handle_matcher handle_matcher
            def handle_matcher(actual, matcher, message=nil, &block)
              RSpec::Given.matcher_called = true
              _rg_rspec_original_handle_matcher(actual, matcher, message, &block)
            end
          end
        end
      end
    end

  else
    RSpec::Given::MONKEY = false
  end

end
