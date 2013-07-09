
module RSpec
  module Given

    # Defined for backwards compatibility
    def self.use_natural_assertions(*args)
      ::Given.use_natural_assertions(*args)
    end
  end
end
