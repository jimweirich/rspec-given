require 'minitest/spec'
require 'given'

require 'given/minispec/before_extension'
require 'given/minispec/context_extension'
require 'given/minispec/framework'
require 'given/minispec/configure'

unless Minitest::Spec.instance_methods.include?(:assertions)
  require 'given/minispec/new_assertions'
end
