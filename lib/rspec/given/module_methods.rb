module RSpec
  module Given
    NATURAL_ASSERTIONS_SUPPORTED = ! defined?(JRUBY_VERSION)

    def self.matcher_called
      @matcher_called
    end

    def self.matcher_called=(value)
      @matcher_called = value
    end

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
      ok_to_use_natural_assertions(enabled)
      @natural_assertions_enabled = enabled
    end

    def self.ok_to_use_natural_assertions(enabled)
      if enabled && ! NATURAL_ASSERTIONS_SUPPORTED
        fail ArgumentError, "Natural Assertions are disabled for JRuby"
      end
    end

    def self.natural_assertions_enabled?
      @natural_assertions_enabled
    end
  end
end
