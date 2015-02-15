require 'minitest/spec'

if defined?(ActiveSupport::TestCase)
  Minitest::Spec.tap do |original_spec|
    Minitest.send(:remove_const, :Spec)
    Minitest::Spec = ActiveSupport::TestCase

    require 'given/minitest/all'

    Minitest.send(:remove_const, :Spec)
    Minitest::Spec = original_spec
  end
else
  require 'given/minitest/all'
end
