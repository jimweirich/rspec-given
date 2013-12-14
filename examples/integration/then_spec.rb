require 'example_helper'

class ToBool
  def initialize(bool)
    @bool = bool
  end
  def to_bool
    @bool
  end
end

describe "Then" do
  context "empty thens with natural assertions" do
    use_natural_assertions_if_supported
    Then { }
  end
  context "thens to_bool/true will pass" do
    use_natural_assertions_if_supported
    Then { ToBool.new(true) }
  end
end
