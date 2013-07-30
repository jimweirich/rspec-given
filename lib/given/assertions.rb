require 'given/natural_assertion'
require 'given/line_extractor'

module Given
  module Assertions

    def self.enable_asserts(enabled=true)
      @enable_asserts = enabled
    end

    def self.enable_preconditions(enabled=true)
      @enable_preconditions = enabled
    end

    def self.enable_postconditions(enabled=true)
      @enable_postconditions = enabled
    end

    def self.asserts?
      @enable_asserts
    end

    def self.preconditions?
      @enable_preconditions
    end

    def self.postconditions?
      @enable_postconditions
    end

    def self.enable_all(enabled=true)
      enable_asserts enabled
      enable_preconditions enabled
      enable_postconditions enabled
    end

    enable_all

    AssertError = Class.new(StandardError)
    PreconditionError = Class.new(AssertError)
    PostconditionError = Class.new(AssertError)

    def Assert(&block)
      return nil unless Given::Assertions.asserts?
      unless block.call
        na = Given::NaturalAssertion.new("Assert", block, self, Given::LineExtractor.new)
        raise AssertError, na.message
      end
    end

    def Precondition(&block)
      return nil unless Given::Assertions.preconditions?
      if block.call
        true
      else
        na = Given::NaturalAssertion.new("Precondition", block, self, Given::LineExtractor.new)
        raise PreconditionError, na.message
      end
    end

    def Postcondition(&block)
      return nil unless Given::Assertions.preconditions?
      if block.call
        true
      else
        na = Given::NaturalAssertion.new("Postcondition", block, self, Given::LineExtractor.new)
        raise PostconditionError, na.message
      end
    end
  end
end
