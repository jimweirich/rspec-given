require 'given/extensions'
require 'given/line_extractor'

module Minitest
  class Spec
    alias original_setup_without_given setup
    def setup
      original_setup_without_given
      _rg_establish_befores
    end
    def _rg_establish_befores
      return if defined?(@_rg_ran_befores) && @_rg_ran_befores
      @_rg_ran_befores = true
      _rg_contexts.each do |context|
        context._rgc_befores.each do |before_block|
          instance_eval(&before_block)
        end
      end
    end
    def self._rgc_befores
      @_rgc_befores ||= []
    end
    def self._gvn_before(&block)
      _rgc_befores << block
    end
  end
end

Minitest::Spec.send(:extend, Given::ClassExtensions)
Minitest::Spec.send(:include, Given::InstanceExtensions)

alias :context :describe
