module RSpec
  module Given
    def self.source_caching_disabled
      @_rg_source_caching_disabled
    end

    def self.source_caching_disabled=(value)
      @_rg_source_caching_disabled = value
    end

    def self.detect_formatters(c)
      format_active = c.formatters.any? { |f| f.class.name !~ /ProgressFormatter/ }
      RSpec::Given.source_caching_disabled = ! format_active
    end

    def self.use_natural_assertions(enabled=true)
      @natural_assertions_enabled = enabled
    end

    def self.natural_assertions_enabled?
      @natural_assertions_enabled
    end
  end
end
