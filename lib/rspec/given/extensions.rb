module RSpec
  module Given
    module Extensions
      def Given(*args,&block)
        if args.first.is_a?(Symbol)
          let(args.first, &block)
        else
          before(&block)
        end
      end

      def Given!(var, &block)
        let!(var, &block)
      end

      def When(*args, &block)
        if args.first.is_a?(Symbol)
          let!(args.first, &block)
        else
          before(&block)
        end
      end
    end
  end
end
