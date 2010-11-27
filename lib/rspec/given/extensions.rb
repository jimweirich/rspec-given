require 'rspec/core/let'

module RSpec
  module Core
    class ExampleGroup
      alias_example_to :Then
    end
  end
end

module RSpec
  module Core
    module Let
      module ClassMethods

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
end
