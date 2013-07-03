require 'spec_helper'
require 'given/failure'

describe Given::Failure do
  Given(:exception) { StandardError.new("Oops") }
  Given(:failure) { Given::Failure.new(exception) }

  Then { lambda { failure.to_s }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure.call }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure.nil? }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure == 0 }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure != 0 }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure =~ 0 }.should raise_error(StandardError, "Oops") }
  Then { lambda { ! failure }.should raise_error(StandardError, "Oops") }

  Then { failure.is_a?(Given::Failure).should be_true }
end
