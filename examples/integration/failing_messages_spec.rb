require 'example_helper'
require 'open3'

describe "Failing Messages" do
  use_natural_assertions_if_supported

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
    And  { ios.out =~ /false *<- array\[index\]\.upcase == value$/ }
    And  { ios.out =~ /"B" *<- array\[index\].upcase$/ }
    And  { ios.out =~ /"b" *<- array\[index\]$/ }
    And  { ios.out =~ /\["a", "b", "c"\] *<- array$/ }
    And  { ios.out =~ /1 *<- index$/ }
    And  { ios.out =~ /"X" *<- value$/ }
  end

  context "when returning false from ToBool" do
    Given(:failing_test) { "to_bool_returns_false.rb" }
    Then { ios.out =~ /Failure\/Error: Then \{ ToBool.new \}/ }
  end

  context "with an oddly formatted then" do
    Given(:failing_test) { "oddly_formatted_then.rb" }
    Then { ios.out =~ /Failure\/Error: Then \{ result == \['a',$/ }
    And  { ios.out =~ /expected: "anything"/ }
    And  { ios.out =~ /to equal: \["a", "a"\]/ }
  end
end
