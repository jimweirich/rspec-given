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
          Regexp.new("\\A" + Regexp.quote(@expected_message_pattern) + "\\Z")
      end
    end

    def matches?(possible_failure)
      if possible_failure.respond_to?(:call)
        make_sure_it_throws_an_exception(possible_failure)
      else
        Given.fail_with("#{description}, but nothing failed")
      end
    end

    def does_not_match?(possible_failure)
      if possible_failure.respond_to?(:call)
        false
      else
        true
      end
    end

    private

    def make_sure_it_throws_an_exception(possible_failure)
      possible_failure.call
      Given.fail_with("Expected an exception")
    rescue Exception => ex
      if ! ex.is_a?(@expected_exception_class)
        Given.fail_with("#{description}, but got #{ex.inspect}")
      elsif @expected_message_pattern !~ ex.message
        Given.fail_with("#{description}, but got #{ex.inspect}")
      else
        true
      end
    end

    private

    def description
      result = "Expected failure with #{@expected_exception_class}"
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
