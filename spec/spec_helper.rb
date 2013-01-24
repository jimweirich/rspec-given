require 'rspec/given'

module ContextMethods
  def use_natural_assertions_if_supported(enabled=true)
    if enabled && ! RSpec::Given::NATURAL_ASSERTIONS_SUPPORTED
      Given {
        pending "Natural assertions are not supported in JRuby"
      }
    else
      use_natural_assertions(enabled)
    end
  end
end

RSpec.configure do |c|
  c.extend(ContextMethods)
end
