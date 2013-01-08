require 'spec_helper'
require 'rspec/given/failure'

describe RSpec::Given::Failure do
  Given(:exception) { StandardError.new("Oops") }
  Given(:failure) { RSpec::Given::Failure.new(exception) }

  Then { lambda { failure.to_s }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure.call }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure.nil? }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure == 0 }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure != 0 }.should raise_error(StandardError, "Oops") }
  Then { lambda { failure =~ 0 }.should raise_error(StandardError, "Oops") }
  Then { lambda { ! failure }.should raise_error(StandardError, "Oops") }

  Then { failure.is_a?(RSpec::Given::Failure).should be_true }
end
