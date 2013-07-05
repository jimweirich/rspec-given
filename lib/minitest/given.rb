require 'given/extensions'
require 'given/line_extractor'

module Minitest
  class Spec
    alias original_setup_without_given setup
    def setup
      original_setup_without_given
      _gvn_establish_befores
    end
    def _gvn_establish_befores
      return if defined?(@_gvn_ran_befores) && @_gvn_ran_befores
      @_gvn_ran_befores = true
      _gvn_contexts.each do |context|
        context._Gvn_befores.each do |before_block|
          instance_eval(&before_block)
        end
      end
    end
    def self._Gvn_befores
      @_Gvn_befores ||= []
    end
    def self._Gvn_before(&block)
      _Gvn_befores << block
    end
  end
end

Minitest::Spec.send(:extend, Given::ClassExtensions)
Minitest::Spec.send(:include, Given::InstanceExtensions)

alias :context :describe
