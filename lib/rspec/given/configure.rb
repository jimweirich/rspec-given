require 'rspec'
require 'given/extensions'
require 'given/fuzzy_number'
require 'given/have_failed'
require 'given/module_methods'

# FIX: move to its own file.
module BeforeHack
  def _Gvn_before(*args, &block)
    before(*args, &block)
  end
end

RSpec.configure do |c|
  c.extend(Given::ClassExtensions)
  c.include(Given::InstanceExtensions)
  c.include(Given::HaveFailed)
  c.include(Given::Fuzzy)
  c.extend(BeforeHack)

  if c.respond_to?(:backtrace_exclusion_patterns)
    c.backtrace_exclusion_patterns << /lib\/rspec\/given/
  else
    c.backtrace_clean_patterns << /lib\/rspec\/given/
  end

  Given.detect_formatters(c)
end
