module ActiveRecord
  class Base
  end
end

module ActiveSupport
  class TestCase < Minitest::Test
    def setup(*args, &block)
    end

    # Remove describe method if present
    class << self
      remove_method :describe
    end if self.respond_to?(:describe) &&
        self.method(:describe).owner == ActiveSupport::TestCase

    # Add spec DSL
    extend ::Minitest::Spec::DSL

    if defined?(ActiveRecord::Base)
      # Use AS::TestCase for the base class when describing a model
      register_spec_type(self) do |desc|
        desc < ActiveRecord::Base if desc.is_a?(Class)
      end
    end
    register_spec_type(self) do |desc, *addl|
      addl.include? :model
    end
  end
end
