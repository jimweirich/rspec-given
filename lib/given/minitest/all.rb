require 'minitest/spec'
require 'given'

require 'given/minitest/before_extension'
require 'given/minitest/context_extension'
require 'given/minitest/failure_must_raise'
require 'given/minitest/framework'
require 'given/minitest/configure'

unless Minitest::Spec.instance_methods.include?(:assertions)
  require 'given/minitest/new_assertions'
end
