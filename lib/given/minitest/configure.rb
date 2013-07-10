
# Configure Minitest to use the Given extensions.

Minitest::Spec.send(:extend,  Given::ClassExtensions)
Minitest::Spec.send(:include, Given::FailureMethod)
Minitest::Spec.send(:include, Given::InstanceExtensions)
Given.use_natural_assertions if Given::NATURAL_ASSERTIONS_SUPPORTED
