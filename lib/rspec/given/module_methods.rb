module RSpec
  module Given
    # Does this platform support natural assertions?
    RBX_IN_USE = (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx')
    NATURAL_ASSERTIONS_SUPPORTED = ! defined?(JRUBY_VERSION) && ! RBX_IN_USE

    def self.matcher_called
      @_matcher_called
    end

    def self.matcher_called=(value)
      @_matcher_called = value
    end

    def self.source_caching_disabled
      @_rg_source_caching_disabled
    end

    def self.source_caching_disabled=(value)
      @_rg_source_caching_disabled = value
    end

    # Detect the formatting requested in the given configuration object.
    #
    # If the format requires it, source caching will be enabled.
    def self.detect_formatters(c)
      format_active = c.formatters.any? { |f| f.class.name !~ /ProgressFormatter/ }
      RSpec::Given.source_caching_disabled = ! format_active
    end

    # Globally enable/disable natural assertions.
    #
    # There is a similar function in Extensions that works at a
    # describe or context scope.
    def self.use_natural_assertions(enabled=true)
      ok_to_use_natural_assertions(enabled)
      @natural_assertions_enabled = enabled
    end

    # TRUE if natural assertions are globally enabled?
    def self.natural_assertions_enabled?
      @natural_assertions_enabled
    end

    # Is is OK to use natural assertions on this platform.
    #
    # An error is raised if the the platform does not support natural
    # assertions and the flag is attempting to enable them.
    def self.ok_to_use_natural_assertions(enabled)
      if enabled && ! NATURAL_ASSERTIONS_SUPPORTED
        fail ArgumentError, "Natural Assertions are disabled for JRuby"
      end
    end

    # Fail an example with the given messages.
    #
    # This should be the only place we reference the RSpec function.
    # Everywhere else in rspec-given should be calling this function.
    def self.fail_with(*args)
      ::RSpec::Expectations.fail_with(*args)
    end

    # Error object used by RSpec to indicate a pending example.
    def self.pending_error
      RSpec::Core::Pending::PendingDeclaredInExample
    end
  end
end
