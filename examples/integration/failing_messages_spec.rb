require 'example_helper'
require 'open3'

describe "Failing Messages" do
  use_natural_assertions

  IOS = Struct.new(:out, :err)

  def run_spec(filename)
    inn, out, err, wait = Open3.popen3("rspec", "examples/integration/failing/#{filename}")
    IOS.new(out.read, err.read)
  end

  When(:ios) { run_spec(failing_test) }

  context "when referencing constants from nested modules" do
    Given(:failing_test) { "module_nesting_spec.rb" }
    Then { ios.err == "" }
    And { ios.out !~ /uninitialized constant RSpec::Given::InstanceExtensions::X/ }
  end

  context "when referencing undefined methods" do
    Given(:failing_test) { "undefined_method_spec.rb" }
    Then { ios.err == "" }
    And { ios.out =~ /undefined local variable or method `xyz'/ }
  end

  context "when breaking down expressions" do
    Given(:failing_test) { "eval_subexpression_spec.rb" }
    Then { ios.err == "" }
    Then { ios.out =~ /false *<- array\[index\]\.upcase == value$/ }
    Then { ios.out =~ /"B" *<- array\[index\].upcase$/ }
    Then { ios.out =~ /"b" *<- array\[index\]$/ }
    Then { ios.out =~ /\["a", "b", "c"\] *<- array$/ }
    Then { ios.out =~ /1 *<- index$/ }
    Then { ios.out =~ /"X" *<- value$/ }
  end
end
