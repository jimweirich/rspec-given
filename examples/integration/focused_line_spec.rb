require 'example_helper'

describe "Focused Line" do
  it "runs only a single test" do
    output = `rspec examples/other/line_example.rb:7`
    given_assert_not_match(/FIRST/, output)
  end
end
