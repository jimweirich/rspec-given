
module Given
  # Does this platform support natural assertions?
  RBX_IN_USE = (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx')
  JRUBY_IN_USE = defined?(JRUBY_VERSION)

  NATURAL_ASSERTIONS_SUPPORTED = ! (JRUBY_IN_USE || RBX_IN_USE)

  def self.framework
    @_gvn_framework
  end

  def self.framework=(framework)
    @_gvn_framework = framework
  end

  def self.source_caching_disabled
    @_gvn_source_caching_disabled
  end

  def self.source_caching_disabled=(value)
    @_gvn_source_caching_disabled = value
  end

  # Detect the formatting requested in the given configuration object.
  #
  # If the format requires it, source caching will be enabled.
  def self.detect_formatters(c)
    format_active = c.formatters.any? { |f| f.class.name !~ /ProgressFormatter/ }
    Given.source_caching_disabled = ! format_active
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
    Given.framework.fail_with(*args)
  end

  # Error object used by RSpec to indicate a pending example.
  def self.pending_error
    Given.framework.pending_error
  end
end
