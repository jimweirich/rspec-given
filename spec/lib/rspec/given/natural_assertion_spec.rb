require 'rspec/given'

describe RSpec::Given::NaturalAssertion do
  before do
    pending "Natural Assertions disabled for JRuby" unless RSpec::Given::NATURAL_ASSERTIONS_SUPPORTED
  end

  Given(:bind) {
    a = 1
    s = "Hello"
    binding
  }
  Given(:lines) { RSpec::Given::LineExtractor.new }
  Given(:nassert) { RSpec::Given::NaturalAssertion.new("Then", block, bind, lines) }

  describe "#content?" do
    context "with empty block" do
      Given(:block) {
        lambda { }
      }
      Then { nassert.should_not have_content }
    end

    context "with block returning false" do
      Given(:block) {
        lambda { false }
      }
      Then { nassert.should have_content }
    end
  end

  describe "detecting RSpec Assertions" do
    context "with should" do
      Given(:block) {
        lambda { a.should == 1 }
      }
      Then { nassert.should be_using_rspec_assertion }
    end

    context "with should in multi-line block" do
      Given(:block) {
        lambda {
          a
            .
          should == 1
        }
      }
      Then { nassert.should be_using_rspec_assertion }
    end

    context "with should_not" do
      Given(:block) {
        lambda { a.should_not == 1 }
      }
      Then { nassert.should be_using_rspec_assertion }
    end

    context "with expect/to" do
      Given(:block) {
        lambda { expect(a).to eq(1) }
      }
      Then { nassert.should be_using_rspec_assertion }
    end

    context "with expect/not_to" do
      Given(:block) {
        lambda { expect(a).not_to eq(1) }
      }
      Then { nassert.should be_using_rspec_assertion }
    end

    context "with expect on several lines" do
      Given(:block) {
        lambda {
          expect(a)
            .
          to eq(1)
        }
      }
      Then { nassert.should be_using_rspec_assertion }
    end

    context "with expect and block" do
      Given(:block) {
        lambda {
          expect { a }.to eq(1)
        }
      }
      Then { nassert.should be_using_rspec_assertion }
    end

    context "with natural assertion" do
      Given(:block) {
        lambda { a == 1 }
      }
      Then { nassert.should_not be_using_rspec_assertion }
    end
  end

  describe "failure messages" do
    Given(:msg) { nassert.message }
    Invariant { msg.should =~ /^Then expression/ }

    context "with equals assertion" do
      Given(:block) {
        lambda { a == 2 }
      }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto equal: +2\b/ }
      Then { msg.should =~ /\bfalse +<- +a == 2\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with equals assertion with do/end" do
      Given(:block) {
        lambda do a == 2 end
      }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto equal: +2\b/ }
      Then { msg.should =~ /\bfalse +<- +a == 2\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with not-equals assertion" do
      Given(:block) {
        lambda { a != 1 }
      }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto not equal: +1\b/ }
      Then { msg.should =~ /\bfalse +<- +a != 1\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with less than assertion" do
      Given(:block) {
        lambda { a < 1 }
      }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto be less than: +1\b/ }
      Then { msg.should =~ /\bfalse +<- +a < 1\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with less than or equal to assertion" do
      Given(:block) {
        lambda { a <= 0 }
      }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto be less or equal to: +0\b/ }
      Then { msg.should =~ /\bfalse +<- +a <= 0\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with greater than assertion" do
      Given(:block) {
        lambda { a > 1 }
      }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto be greater than: +1\b/ }
      Then { msg.should =~ /\bfalse +<- +a > 1\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with greater than or equal to assertion" do
      Given(:block) {
        lambda { a >= 3 }
      }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto be greater or equal to: +3\b/ }
      Then { msg.should =~ /\bfalse +<- +a >= 3\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with match assertion" do
      Given(:block) {
        lambda { s =~ /HI/ }
      }
      Then { msg.should =~ /\bexpected: +"Hello"$/ }
      Then { msg.should =~ /\bto match: +\/HI\/$/ }
      Then { msg.should =~ /\bnil +<- +s =~ \/HI\/$/ }
      Then { msg.should =~ /"Hello" +<- +s$/ }
    end

    context "with not match assertion" do
      Given(:block) {
        lambda { s !~ /Hello/ }
      }
      Then { msg.should =~ /\bexpected: +"Hello"$/ }
      Then { msg.should =~ /\bto not match: +\/Hello\/$/ }
      Then { msg.should =~ /\bfalse +<- +s !~ \/Hello\/$/ }
      Then { msg.should =~ /"Hello" +<- +s$/ }
    end

    context "with exception" do
      Given(:ary) { nil }
      Given(:block) {
        lambda { ary[1] == 3 }
      }
      Then { msg.should =~ /\bexpected: +NoMethodError/ }
      Then { msg.should =~ /\bto equal: +3$/ }
      Then { msg.should =~ /\bNoMethodError.+NilClass\n +<- +ary\[1\] == 3$/ }
      Then { msg.should =~ /\bNoMethodError.+NilClass\n +<- +ary\[1\]$/ }
      Then { msg.should =~ /\bnil +<- +ary$/ }
    end
  end

  describe "bad Then blocks" do
    context "with no statements" do
      Given(:block) {
        lambda {  }
      }
      When(:result) { nassert.message }
# FIX: WHY IS THIS COMMENTED OUT?
#      Then { result.should have_failed(RSpec::Given::InvalidThenError) }
    end

    context "with multiple statements" do
      Given(:block) {
        lambda {
          ary = nil
          ary[1] == 3
        }
      }
      When(:result) { nassert.message }
      Then { result.should have_failed(RSpec::Given::InvalidThenError, /multiple.*statements/i) }
    end

  end
end
