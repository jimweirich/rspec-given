require 'spec_helper'

describe "Configuration Options" do
  let(:trace) { [] }

  describe "inherited options" do
    context "Outer" do
      _Gvn_context_info[:name] = "Outer"
      _Gvn_context_info[:outer] = true

      Then { expect(_gvn_info(:name)).to eq("Outer") }
      Then { expect(_gvn_info(:outer)).to eq(true) }
      Then { expect(_gvn_info(:inner)).to eq(nil) }

      context "Inner" do
        _Gvn_context_info[:name] = "Inner"
        _Gvn_context_info[:inner] = true

        Then { expect(_gvn_info(:name)).to eq("Inner") }
        Then { expect(_gvn_info(:outer)).to eq(true) }
        Then { expect(_gvn_info(:inner)).to eq(true) }
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
      Then { expect(_gvn_need_na_message?(nassert)).to be_falsy }

      context "overridden locally" do
        use_natural_assertions_if_supported
        Then { expect(_gvn_need_na_message?(nassert)).to be_truthy }
      end
    end

    context "with global configuration enabled" do
      When { Given.use_natural_assertions }
      Then { expect(_gvn_need_na_message?(nassert)).to be_truthy }

      context "overridden locally" do
        use_natural_assertions false
        Then { expect(_gvn_need_na_message?(nassert)).to be_falsy }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then {
          if RSpec::Given::MONKEY
            # If RSpec was successfully patched to record matchers,
            # then the "need NA" logic will ignore possible matches in
            # the source code.
            expect(_gvn_need_na_message?(nassert)).to be_truthy
          else
            # If RSpec was not successfully patched to record
            # matchers, then the "need NA" logic will check for
            # should/expect in the source.
            expect(_gvn_need_na_message?(nassert)).to be_falsy
          end
        }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { expect(_gvn_need_na_message?(nassert)).to be_truthy }
      end

      context "without rspec assertion and no content" do
        Given(:rspec) { false }
        Given(:content) { false }
        Then { expect(_gvn_need_na_message?(nassert)).to be_falsy }
      end
    end

    context "with global configuration set to always" do
      When { Given.use_natural_assertions :always }
      Then { expect(_gvn_need_na_message?(nassert)).to be_truthy }

      context "overridden locally" do
        use_natural_assertions false
        Then { expect(_gvn_need_na_message?(nassert)).to be_falsy }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { expect(_gvn_need_na_message?(nassert)).to be_truthy }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { expect(_gvn_need_na_message?(nassert)).to be_truthy }
      end

      context "without rspec assertion and no content" do
        Given(:rspec) { false }
        Given(:content) { false }
        Then { expect(_gvn_need_na_message?(nassert)).to be_falsy }
      end
    end

    context "with global configuration disabled" do
      When { Given.use_natural_assertions false }
      Then { expect(_gvn_need_na_message?(nassert)).to be_falsy }

      context "overridden locally" do
        use_natural_assertions_if_supported(true)
        Then { expect(_gvn_need_na_message?(nassert)).to be_truthy }
      end

      context "with rspec assertion" do
        Given(:rspec) { true }
        Then { expect(_gvn_need_na_message?(nassert)).to be_falsy }
      end

      context "without rspec assertion" do
        Given(:rspec) { false }
        Then { expect(_gvn_need_na_message?(nassert)).to be_falsy }
      end
    end

  end
end
