require 'spec_helper'

describe "RSpec::Given.use_natural_assertions" do
  context "when in JRuby" do
    When(:result) { ::Given.use_natural_assertions }

    if ::Given::NATURAL_ASSERTIONS_SUPPORTED
      Then { expect(result).to_not have_failed }
    else
      Then { expect(result).to have_failed(ArgumentError) }
    end
  end
end
