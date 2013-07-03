require 'given/extensions'
require 'given/line_extractor'

Minitest::Spec.send(:extend, Given::ClassExtensions)
Minitest::Spec.send(:include, Given::InstanceExtensions)

alias :context :describe
