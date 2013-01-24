require 'rspec/given'
require 'example_helper'

describe "Then" do
  context "empty thens with natural assertions" do
    use_natural_assertions_if_supported
    Then { }
  end
end
