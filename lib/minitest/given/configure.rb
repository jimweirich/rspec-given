
# Configure Minitest to use the Given extensions.

Minitest::Spec.send(:extend, Given::ClassExtensions)
Minitest::Spec.send(:include, Given::InstanceExtensions)
