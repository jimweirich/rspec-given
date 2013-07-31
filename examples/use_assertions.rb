require 'given/module_methods'

if Given::NATURAL_ASSERTIONS_SUPPORTED

  require 'given/assertions'
  require 'given/fuzzy_number'

  include Given::Assertions
  include Given::Fuzzy

  def sqrt(n)
    Precondition { n >= 0 }
    result = Math.sqrt(n)
    Postcondition { result ** 2 == about(n) }
    result
  end

  def sqrt_bad_postcondition(n)
    Precondition { n >= 0 }
    result = Math.sqrt(n)
    Postcondition { result ** 2 == about(n+1) }
    result
  end

  def use_assert(n)
    Assert { n == 1 }
  end

  def should_fail
    begin
      yield
      fail "Expected error"
    rescue Given::Assertions::AssertError => ex
      true
    end
  end

  sqrt(1)
  sqrt(2)
  sqrt(0)

  should_fail { sqrt(-1) }
  should_fail { sqrt_bad_postcondition(1) }

  use_assert(1)
  should_fail { use_assert(0) }
end
