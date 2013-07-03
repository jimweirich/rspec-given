module NaturalAssertionControl
  def use_natural_assertions_if_supported(enabled=true)
    if enabled && ! Given::NATURAL_ASSERTIONS_SUPPORTED
      Given {
        pending "Natural assertions are not supported in JRuby"
      }
    else
      use_natural_assertions(enabled)
    end
  end
end

RSpec.configure do |c|
  c.extend(NaturalAssertionControl)
end
