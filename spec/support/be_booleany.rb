
unless RSpec::Matchers::BuiltIn.constants.include?(:BeTruthy)

  # Define the be_truthy/be_falsy matchers for versions of RSpec that
  # don't include them.

  def be_truthy
    be_true
  end

  def be_falsy
    be_false
  end

end
