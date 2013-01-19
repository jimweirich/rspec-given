require 'spec_helper'

describe "Configuration Options" do
  let(:trace) { [] }

  describe "inherited options" do
    context "Outer" do
      _rgc_context_info[:name] = "Outer"
      _rgc_context_info[:outer] = true

      Then { _rg_info(:name).should == "Outer" }
      Then { _rg_info(:outer).should == true }
      Then { _rg_info(:inner).should == nil }

      context "Inner" do
        _rgc_context_info[:name] = "Inner"
        _rgc_context_info[:inner] = true

        Then { _rg_info(:name).should == "Inner" }
        Then { _rg_info(:outer).should == true }
        Then { _rg_info(:inner).should == true }
      end
    end
  end

  describe "Global natural assertion configuration" do
    Given(:rspec) { false }
    Given(:content) { true }
    Given(:nassert) { stub(:using_rspec_assertion? => rspec, :has_content? => content) }

    after do
      RSpec::Given.use_natural_assertions false
    end

    context "with no explicit word on natural assertions" do
      Then { _rg_need_na_message?(nassert).should be_false }

      context "overridden locally" do
        use_natural_assertions
        Then { _rg_need_na_message?(nassert).should be_true }
      end
    end

    context "with global configuration enabled" do
      When { RSpec::Given.use_natural_assertions }
      Then { _rg_need_na_message?(nassert).should be_true }

      context "overridden locally" do
        use_natural_assertions false
        Then { _rg_need_na_message?(nassert).should be_false }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then {
          if RSpec::Given::MONKEY
            # If RSpec was successfully patched to record matchers,
            # then the "need NA" logic will ignore possible matches in
            # the source code.
            _rg_need_na_message?(nassert).should be_true
          else
            # If RSpec was not successfully patched to record
            # matchers, then the "need NA" logic will check for
            # should/expect in the source.
            _rg_need_na_message?(nassert).should be_false
          end
        }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _rg_need_na_message?(nassert).should be_true }
      end

      context "without rspec assertion and no content" do
        Given(:rspec) { false }
        Given(:content) { false }
        Then { _rg_need_na_message?(nassert).should be_false }
      end
    end

    context "with global configuration set to always" do
      When { RSpec::Given.use_natural_assertions :always }
      Then { _rg_need_na_message?(nassert).should be_true }

      context "overridden locally" do
        use_natural_assertions false
        Then { _rg_need_na_message?(nassert).should be_false }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { _rg_need_na_message?(nassert).should be_true }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _rg_need_na_message?(nassert).should be_true }
      end

      context "without rspec assertion and no content" do
        Given(:rspec) { false }
        Given(:content) { false }
        Then { _rg_need_na_message?(nassert).should be_false }
      end
    end

    context "with global configuration disabled" do
      When { RSpec::Given.use_natural_assertions false }
      Then { _rg_need_na_message?(nassert).should be_false }

      context "overridden locally" do
        use_natural_assertions true
        Then { _rg_need_na_message?(nassert).should be_true }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { _rg_need_na_message?(nassert).should be_false }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _rg_need_na_message?(nassert).should be_false }
      end
    end

  end
end
