require 'rspec'
require 'rspec/given/extensions'
require 'rspec/given/fuzzy_number'
require 'rspec/given/have_failed'
require 'rspec/given/module_methods'

RSpec.configure do |c|
  c.extend(RSpec::Given::ClassExtensions)
  c.include(RSpec::Given::InstanceExtensions)
  c.include(RSpec::Given::HaveFailed)
  c.include(RSpec::Given::Fuzzy)

  c.backtrace_clean_patterns << /lib\/rspec\/given/

  RSpec::Given.detect_formatters(c)
end
