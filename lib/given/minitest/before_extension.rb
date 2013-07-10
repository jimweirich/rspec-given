
# The before blocks defined in Minitest are inadequate for our use.
# This before_extension file allows us to use real before blocks.

module Minitest
  class Spec

    # Redefine setup to trigger before chains
    alias original_setup_without_given setup
    def setup
      original_setup_without_given
      _gvn_establish_befores
    end

    # Establish the before blocks
    def _gvn_establish_befores
      return if defined?(@_gvn_ran_befores) && @_gvn_ran_befores
      @_gvn_ran_befores = true
      _gvn_contexts.each do |context|
        context._Gvn_before_blocks.each do |before_block|
          instance_eval(&before_block)
        end
      end
    end

    # Lazy accessor for Given's before blocks
    def self._Gvn_before_blocks
      @_Gvn_before_blocks ||= []
    end

    # Define a Given style before block
    def self._Gvn_before(&block)
      _Gvn_before_blocks << block
    end
  end
end
