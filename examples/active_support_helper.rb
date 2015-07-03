module ActiveSupport
  class TestCase < Minitest::Test
    # Add spec DSL
    extend ::Minitest::Spec::DSL

    register_spec_type(self) do |desc, *addl|
      addl.include? :model
    end
  end
end
