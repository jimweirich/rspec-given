module Rake
  module DSL

    # Define run so that it will run in a bundle clean environment.

    if defined?(Bundler)
      def nobundle
        Bundler.with_clean_env { yield }
      end
    else
      def nobundle
        yield
      end
    end

  end
end
