module NaturalAssertionControl
  def skip_natural_assertions_if_not_supported
    if !Given::NATURAL_ASSERTIONS_SUPPORTED
      Given { pending "This test requires a Ruby runtime with full natural assertions support." }
    end
  end
end

RSpec.configure { |c| c.extend(NaturalAssertionControl) }
