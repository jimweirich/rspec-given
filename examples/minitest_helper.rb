
module GivenAssertions
  def given_assert(cond)
    assert cond
  end

  def given_assert_equal(expected, actual)
    actual.must_equal(expected)
  end

  def given_assert_match(pattern, actual)
    actual.must_match(pattern)
  end

  def given_assert_not_match(pattern, actual)
    actual.wont_match(pattern)
  end
end

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

module LetBang
  def let!(name, &block)
    let(name, &block)
    # FIX: This is inadequate if more than one before block is defined.
    before { __send__(name) }
  end
end

Minitest::Spec.send(:include, GivenAssertions)
Minitest::Spec.send(:extend, LetBang)
include NaturalAssertionControl
