require 'rspec/given'

describe "Then with nesting" do
  use_natural_assertions
  def self.xyz
    nil
  end
  Then { xyz }
end
