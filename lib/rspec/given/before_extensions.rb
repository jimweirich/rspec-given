
module RSpec
  module Given
    module BeforeHack

      # Some frameworks don't support a robust before block, so we
      # always use this one. In RSpec, we just delegate to the real
      # before block handler.
      def _Gvn_before(*args, &block)
        before(*args, &block)
      end

    end
  end
end
