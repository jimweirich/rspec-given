module Given

  class FailureMatcher
    def initialize(exception_class, message_pattern)
      @no_pattern = false
      @expected_exception_class = exception_class
      @expected_message_pattern = message_pattern
      if @expected_message_pattern.nil?
        @expected_message_pattern = //
        @no_pattern = true
      elsif @expected_message_pattern.is_a?(String)
        @expected_message_pattern =
          Regexp.new("\\A" + Regexp.quote(@expected_message_pattern) + "\\z")
      end
    end

    def ==(other)
      if other.respond_to?(:call)
        matches?(other)
      else
        super
      end
    end

    def !=(other)
      if other.respond_to?(:call)
        does_not_match?(other)
      else
        super
      end
    end

    def matches?(possible_failure)
      if possible_failure.respond_to?(:call)
        match_or_fail(possible_failure)
      else
        Given.fail_with("#{description}, but nothing failed")
      end
    end

    def does_not_match?(possible_failure)
      if possible_failure.respond_to?(:call)
        mismatch_or_fail(possible_failure)
      else
        true
      end
    end

    def inspect
      result = "<Failure on #{@expected_exception_class}"
      result << " matching #{@expected_message_pattern.inspect}" unless @no_pattern
      result << ">"
    end

    private

    def match_or_fail(possible_failure)
      ex = extract_exception(possible_failure)
      match_exception(ex) ||
        Given.fail_with("#{description}, but got #{ex.inspect}")
    end

    def mismatch_or_fail(possible_failure)
      ex = extract_exception(possible_failure)
      (! match_exception(ex)) ||
        Given.fail_with("#{unexpected_description}, but got #{ex.inspect}")
    end

    def match_exception(ex)
      ex.is_a?(@expected_exception_class) && @expected_message_pattern =~ ex.message
    end

    def extract_exception(possible_failure)
      possible_failure.call
      Given.fail_with("Expected an exception")
      return nil
    rescue Exception => ex
      return ex
    end

    def description
      result = "Expected failure with #{@expected_exception_class}"
      result << " matching #{@expected_message_pattern.inspect}" unless @no_pattern
      result
    end

    def unexpected_description
      result = "Did not expect failure with #{@expected_exception_class}"
      result << " matching #{@expected_message_pattern.inspect}" unless @no_pattern
      result
    end
  end

  module FailureMethod
    def Failure(exception_class=Exception, message_pattern=nil)
      FailureMatcher.new(exception_class, message_pattern)
    end
  end

end
