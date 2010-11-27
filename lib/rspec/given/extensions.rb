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
            let!(:given_result,&block)
          end
        end

        def When(*args, &block)
          sym = args.first.is_a?(Symbol) ? args.first : :when_result
          let!(sym, &block)
        end
      end
    end
  end
end
