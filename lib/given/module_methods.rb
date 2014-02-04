
module Given
  # Does this platform support natural assertions?
  RBX_IN_USE = (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx')
  JRUBY_IN_USE = defined?(JRUBY_VERSION)
  OLD_JRUBY_IN_USE = JRUBY_IN_USE && (JRUBY_VERSION < '1.7.5')

  NATURAL_ASSERTIONS_SUPPORTED = ! (OLD_JRUBY_IN_USE || RBX_IN_USE)

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

  # Return file and line number where the block is defined.
  def self.location_of(block)
    eval "[__FILE__, __LINE__]", block.binding
  end

  # Methods forwarded to the framework object.

  # Fail an example with the given messages.
  def self.fail_with(*args)
    Given.framework.fail_with(*args)
  end

  # Mark the start of a Then assertion evaluation.
  def self.start_evaluation(*args)
    Given.framework.start_evaluation(*args)
  end

  # Were there any explicit framework assertions made during the
  # execution of the Then block?
  def self.explicit_assertions?(*args)
    Given.framework.explicit_assertions?(*args)
  end

  # Increment the number of assertions made in the framework.
  def self.count_assertion(*args)
    Given.framework.count_assertion(*args)
  end

  # Error object used by the current framework to indicate a pending
  # example.
  def self.pending_error
    Given.framework.pending_error
  end
end
