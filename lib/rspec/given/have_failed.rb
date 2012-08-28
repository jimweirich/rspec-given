module RSpec
  module Given
    module HaveFailed
      def have_failed(*args, &block)
        raise_error(*args, &block)
      end
    end
  end
end
