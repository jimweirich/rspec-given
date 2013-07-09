
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

  def given_assert_raises(error, pattern=//, &block)
    ex = assert_raises(error, &block)
    ex.message.must_match(pattern)
  end
end

module NaturalAssertionControl
  def use_natural_assertions_if_supported(enabled=true)
    if enabled && ! Given::NATURAL_ASSERTIONS_SUPPORTED
      Given {
        skip "Natural assertions are not supported in JRuby"
      }
    else
      use_natural_assertions(enabled)
    end
  end
end

Minitest::Spec.send(:include, GivenAssertions)
include NaturalAssertionControl
