
# Configure Minitest to use the Given extensions.
if defined?(ActiveSupport::TestCase)
  ActiveSupport::TestCase.send(:extend, Given::ClassExtensions)
  ActiveSupport::TestCase.send(:include, Given::FailureMethod)
  ActiveSupport::TestCase.send(:include, Given::InstanceExtensions)
end
Minitest::Spec.send(:extend,  Given::ClassExtensions)
Minitest::Spec.send(:include, Given::FailureMethod)
Minitest::Spec.send(:include, Given::InstanceExtensions)
Given.use_natural_assertions if Given::NATURAL_ASSERTIONS_SUPPORTED
