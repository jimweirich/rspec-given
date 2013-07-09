require 'spec_helper'

describe "RSpec::Given.use_natural_assertions" do
  context "when in JRuby" do
    When(:result) { ::Given.use_natural_assertions }

    if ::Given::NATURAL_ASSERTIONS_SUPPORTED
      Then { result.should_not have_failed }
    else
      Then { result.should have_failed(ArgumentError) }
    end
  end
end
