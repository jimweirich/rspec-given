
module Given

  # Failure objects will raise the given exception whenever you try
  # to send it *any* message.
  class Failure < BasicObject
    undef_method :==, :!=, :!

    def initialize(exception)
      @exception = exception
    end

    def is_a?(klass)
      klass == Failure
    end

    def ==(other)
      if failed_matcher?(other)
        other.matches?(self)
      else
        die
      end
    end

    def !=(other)
      if failed_matcher?(other)
        ! other.matches?(self)
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

    def failed_matcher?(other)
      # FIX: for multi-framework
      other.is_a?(::Given::HaveFailed::HaveFailedMatcher)
    end

  end
end
