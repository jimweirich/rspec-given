require 'rspec/given'

class ToBool
  def to_bool
    false
  end
end

describe "Then with nesting" do
  use_natural_assertions
  Then { ToBool.new }
end
