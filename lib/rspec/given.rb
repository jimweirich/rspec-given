if !defined?(RSpec) && defined?(Spec::Version::STRING) && Spec::Version::STRING =~ /^1\./
  require 'rspec/given/rspec1_given'
else
  require 'rspec/given/version'
  require 'rspec/given/extensions'
  require 'rspec/given/configure'
end
