module Given

  class Failure
    # Minitest expectation method. Since Failure inherits from
    # BasicObject, we need to add this method explicitly.
    def must_raise(*args)
      ::Minitest::Spec.current.assert_raises(*args) do
        die
      end
    end
  end

end
