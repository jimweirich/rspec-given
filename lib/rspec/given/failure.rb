module RSpec
  module Given

    # Failure objects will raise the given exception whenever you try
    # to send it *any* message.
    class Failure < BasicObject
      undef_method :==, :!=, :!

      def initialize(exception)
        @exception = exception
      end

      def method_missing(sym, *args, &block)
        ::Kernel.raise @exception
      end
    end
  end
end
