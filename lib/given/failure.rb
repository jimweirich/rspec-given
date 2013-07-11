
module Given

  # Failure objects will raise the given exception whenever you try
  # to send it *any* message.
  class Failure < BasicObject
    undef_method :==, :!=, :!

    # Evaluate a block. If an exception is raised, capture it in a
    # Failure object. Explicitly listed exceptions are passed thru
    # without capture.
    def self.capture(*exceptions)
      begin
        yield
      rescue *exceptions => ex
        raise
      rescue ::Exception => ex
        new(ex)
      end
    end

    # Minitest expectation method. Since Failure inherits from
    # BasicObject, we need to add this method explicitly.
    def must_raise(*args)
      ::Minitest::Spec.current.assert_raises(*args) do
        die
      end
    end

    def initialize(exception)
      @exception = exception
    end

    def is_a?(klass)
      klass == Failure
    end

    def ==(other)
      if failure_matcher?(other)
        other.matches?(self)
      else
        die
      end
    end

    def !=(other)
      if failure_matcher?(other)
        other.does_not_match?(self)
      else
        die
      end
    end

    def method_missing(sym, *args, &block)
      die
    end

    def respond_to?(method_symbol)
      method_symbol == :call ||
        method_symbol == :== ||
        method_symbol == :!= ||
        method_symbol == :is_a?
    end

    private

    def die
      ::Kernel.raise @exception
    end

    def failure_matcher?(other)
      other.is_a?(::Given::FailureMatcher) ||
        (defined?(::RSpec) && other.is_a?(::RSpec::Given::HaveFailed::HaveFailedMatcher))
    end

  end
end
