require 'rspec'
require 'rspec/given' unless defined?(RSpec::Given)

RSpec.configure do |c|
  c.extend(Given::ClassExtensions)
  c.include(Given::InstanceExtensions)
  c.include(Given::Fuzzy)
  c.include(Given::FailureMethod)
  c.extend(RSpec::Given::BeforeHack)
  c.include(RSpec::Given::HaveFailed)

  if c.respond_to?(:backtrace_exclusion_patterns)
    c.backtrace_exclusion_patterns << /lib\/rspec\/given/
  else
    c.backtrace_clean_patterns << /lib\/rspec\/given/
  end

  Given.use_natural_assertions if Given::NATURAL_ASSERTIONS_SUPPORTED
  Given.source_caching_disabled = false
end
