require 'spec_helper'

describe "RSpec::Given.use_natural_assertions" do
  When(:result) { ::Given.use_natural_assertions }

  Then { expect(result).to_not have_failed }
end
