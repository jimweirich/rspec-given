
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

    # Create a failure object that will rethrow the given exception
    # whenever an undefined method is called.
    def initialize(exception)
      @exception = exception
    end

    # Failure objects will respond to #is_a?.
    def is_a?(klass)
      klass == Failure
    end

    # Failure objects may be compared for equality. If the comparison
    # object is not a matcher, then the exception is re-raised.
    def ==(other)
      if failure_matcher?(other)
        other.matches?(self)
      else
        die
      end
    end

    # Failure objects may be compared for in-equality. If the comparison
    # object is not a matcher, then the exception is re-raised.
    def !=(other)
      if failure_matcher?(other)
        other.does_not_match?(self)
      else
        die
      end
    end

    # Most methods will just re-raise the captured exception.
    def method_missing(sym, *args, &block)
      die
    end

    # Report that we respond to a limited number of methods.
    def respond_to?(method_symbol)
      method_symbol == :call ||
        method_symbol == :== ||
        method_symbol == :!= ||
        method_symbol == :is_a? ||
        method_symbol == :to_bool
    end

    private

    # Re-raise the captured exception.
    def die
      ::Kernel.raise @exception
    end

    # Is the comparison object a failure matcher?
    def failure_matcher?(other)
      other.respond_to?(:matches?) && other.respond_to?(:does_not_match?)
    end
  end

end
