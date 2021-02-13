# Configure ActiveSupprt::TestCase to use the Given extensions.
if defined?(ActiveSupport::TestCase)
  ActiveSupport::TestCase.send(:extend, Given::ClassExtensions)
  ActiveSupport::TestCase.send(:extend, Given::MiniTest::ClassExtensions)
  ActiveSupport::TestCase.send(:include, Given::FailureMethod)
  ActiveSupport::TestCase.send(:include, Given::InstanceExtensions)
  ActiveSupport::TestCase.send(:include, Given::MiniTest::InstanceExtensions)
end
# Configure Minitest to use the Given extensions.
Minitest::Spec.send(:extend,  Given::ClassExtensions)
Minitest::Spec.send(:extend, Given::MiniTest::ClassExtensions)
Minitest::Spec.send(:include, Given::FailureMethod)
Minitest::Spec.send(:include, Given::InstanceExtensions)
Minitest::Spec.send(:include, Given::MiniTest::InstanceExtensions)
Given.use_natural_assertions
