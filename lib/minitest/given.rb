require 'minitest/spec'
require 'given'

require 'minitest/given/before_extension'
require 'minitest/given/context_extension'
require 'minitest/given/framework'
require 'minitest/given/configure'

unless Minitest::Spec.instance_methods.include?(:assertions)
  require 'minitest/given/new_assertions'
end
