require 'spec_helper'

describe "Configuration Options" do
  let(:trace) { [] }

  describe "inherited options" do
    context "Outer" do
      _Gvn_context_info[:name] = "Outer"
      _Gvn_context_info[:outer] = true

      Then { _gvn_info(:name).should == "Outer" }
      Then { _gvn_info(:outer).should == true }
      Then { _gvn_info(:inner).should == nil }

      context "Inner" do
        _Gvn_context_info[:name] = "Inner"
        _Gvn_context_info[:inner] = true

        Then { _gvn_info(:name).should == "Inner" }
        Then { _gvn_info(:outer).should == true }
        Then { _gvn_info(:inner).should == true }
      end
    end
  end

  describe "Global natural assertion configuration" do
    unless Given::NATURAL_ASSERTIONS_SUPPORTED
      before do
        pending "Natural assertions are not supported in JRuby"
      end
    end

    before do
      Given.use_natural_assertions false
    end

    Given(:rspec) { false }
    Given(:content) { true }
    Given(:nassert) { double(:using_rspec_assertion? => rspec, :has_content? => content) }

    after do
      Given.use_natural_assertions false
    end

    context "with no explicit word on natural assertions" do
      Then { _gvn_need_na_message?(nassert).should be_false }

      context "overridden locally" do
        use_natural_assertions_if_supported
        Then { _gvn_need_na_message?(nassert).should be_true }
      end
    end

    context "with global configuration enabled" do
      When { Given.use_natural_assertions }
      Then { _gvn_need_na_message?(nassert).should be_true }

      context "overridden locally" do
        use_natural_assertions false
        Then { _gvn_need_na_message?(nassert).should be_false }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then {
          if RSpec::Given::MONKEY
            # If RSpec was successfully patched to record matchers,
            # then the "need NA" logic will ignore possible matches in
            # the source code.
            _gvn_need_na_message?(nassert).should be_true
          else
            # If RSpec was not successfully patched to record
            # matchers, then the "need NA" logic will check for
            # should/expect in the source.
            _gvn_need_na_message?(nassert).should be_false
          end
        }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _gvn_need_na_message?(nassert).should be_true }
      end

      context "without rspec assertion and no content" do
        Given(:rspec) { false }
        Given(:content) { false }
        Then { _gvn_need_na_message?(nassert).should be_false }
      end
    end

    context "with global configuration set to always" do
      When { Given.use_natural_assertions :always }
      Then { _gvn_need_na_message?(nassert).should be_true }

      context "overridden locally" do
        use_natural_assertions false
        Then { _gvn_need_na_message?(nassert).should be_false }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { _gvn_need_na_message?(nassert).should be_true }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _gvn_need_na_message?(nassert).should be_true }
      end

      context "without rspec assertion and no content" do
        Given(:rspec) { false }
        Given(:content) { false }
        Then { _gvn_need_na_message?(nassert).should be_false }
      end
    end

    context "with global configuration disabled" do
      When { Given.use_natural_assertions false }
      Then { _gvn_need_na_message?(nassert).should be_false }

      context "overridden locally" do
        use_natural_assertions_if_supported(true)
        Then { _gvn_need_na_message?(nassert).should be_true }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { _gvn_need_na_message?(nassert).should be_false }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { _gvn_need_na_message?(nassert).should be_false }
      end
    end

  end
end
