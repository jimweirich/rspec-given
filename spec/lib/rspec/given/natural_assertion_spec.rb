require 'rspec/given'
require 'spec_helper'

describe "Environmental Access" do
  X = 1
  Given(:a) { 2 }
  FauxThen { X + a }

  Then { block_result.should == 3 }
  Then { na.evaluate("X").should == 1 }
  Then { na.evaluate("a").should == 2 }
  Then { na.evaluate("X+a").should == 3 }
end

module Nested
  X = 1
  describe "Environmental Access with Nested modules" do
    Given(:a) { 2 }
    FauxThen { X + a }
    Then { block_result.should == 3 }
    Then { na.evaluate("a").should == 2 }
    Then { na.evaluate("X").should == 1 }
    Then { na.evaluate("a+X").should == 3 }
  end
end

describe RSpec::Given::NaturalAssertion do
  before do
    pending "Natural Assertions disabled for JRuby" unless RSpec::Given::NATURAL_ASSERTIONS_SUPPORTED
  end

  describe "#content?" do
    context "with empty block" do
      FauxThen { }
      Then { na.should_not have_content }
    end
    context "with block returning false" do
      FauxThen { false }
      Then { na.should have_content }
    end
  end

  describe "detecting RSpec Assertions" do
    context "with should" do
      FauxThen { a.should == 1 }
      Then { na.should be_using_rspec_assertion }
    end

    context "with should_not" do
      FauxThen { a.should_not == 1 }
      Then { na.should be_using_rspec_assertion }
    end

    context "with expect/to" do
      FauxThen { expect(a).to eq(1) }
      Then { na.should be_using_rspec_assertion }
    end

    context "with expect/not_to" do
      FauxThen { expect(a).not_to eq(1) }
      Then { na.should be_using_rspec_assertion }
    end

    context "with expect and block" do
      FauxThen { expect { a }.to eq(1) }
      Then { na.should be_using_rspec_assertion }
    end

    context "with natural assertion" do
      FauxThen { a == 1 }
      Then { na.should_not be_using_rspec_assertion }
    end
  end

  describe "failure messages" do
    let(:msg) { na.message }
    Invariant { msg.should =~ /^FauxThen expression/ }

    context "with equals assertion" do
      Given(:a) { 1 }
      FauxThen { a == 2 }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto equal: +2\b/ }
      Then { msg.should =~ /\bfalse +<- +a == 2\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with equals assertion with do/end" do
      Given(:a) { 1 }
      FauxThen do a == 2 end
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto equal: +2\b/ }
      Then { msg.should =~ /\bfalse +<- +a == 2\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with not-equals assertion" do
      Given(:a) { 1 }
      FauxThen { a != 1 }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto not equal: +1\b/ }
      Then { msg.should =~ /\bfalse +<- +a != 1\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with less than assertion" do
      Given(:a) { 1 }
      FauxThen { a < 1 }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto be less than: +1\b/ }
      Then { msg.should =~ /\bfalse +<- +a < 1\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with less than or equal to assertion" do
      Given(:a) { 1 }
      FauxThen { a <= 0 }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto be less or equal to: +0\b/ }
      Then { msg.should =~ /\bfalse +<- +a <= 0\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with greater than assertion" do
      Given(:a) { 1 }
      FauxThen { a > 1 }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto be greater than: +1\b/ }
      Then { msg.should =~ /\bfalse +<- +a > 1\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with greater than or equal to assertion" do
      Given(:a) { 1 }
      FauxThen { a >= 3 }
      Then { msg.should =~ /\bexpected: +1\b/ }
      Then { msg.should =~ /\bto be greater or equal to: +3\b/ }
      Then { msg.should =~ /\bfalse +<- +a >= 3\b/ }
      Then { msg.should =~ /\b1 +<- +a\b/ }
    end

    context "with match assertion" do
      Given(:s) { "Hello" }
      FauxThen { s =~ /HI/ }
      Then { msg.should =~ /\bexpected: +"Hello"$/ }
      Then { msg.should =~ /\bto match: +\/HI\/$/ }
      Then { msg.should =~ /\bnil +<- +s =~ \/HI\/$/ }
      Then { msg.should =~ /"Hello" +<- +s$/ }
    end

    context "with not match assertion" do
      Given(:s) { "Hello" }
      FauxThen { s !~ /Hello/ }
      Then { msg.should =~ /\bexpected: +"Hello"$/ }
      Then { msg.should =~ /\bto not match: +\/Hello\/$/ }
      Then { msg.should =~ /\bfalse +<- +s !~ \/Hello\/$/ }
      Then { msg.should =~ /"Hello" +<- +s$/ }
    end

    context "with exception" do
      Given(:ary) { nil }
      FauxThen { ary[1] == 3 }
      Then { msg.should =~ /\bexpected: +NoMethodError/ }
      Then { msg.should =~ /\bto equal: +3$/ }
      Then { msg.should =~ /\bNoMethodError.+NilClass\n +<- +ary\[1\] == 3$/ }
      Then { msg.should =~ /\bNoMethodError.+NilClass\n +<- +ary\[1\]$/ }
      Then { msg.should =~ /\bnil +<- +ary$/ }
    end
  end

  describe "bad Then blocks" do
    context "with no statements" do
      FauxThen {  }
      When(:result) { na.message }
      Then { result.should_not have_failed(RSpec::Given::InvalidThenError) }
    end

    context "with multiple statements" do
      FauxThen {
        ary = nil
        ary[1] == 3
      }
      When(:result) { na.message }
      Then { result.should have_failed(RSpec::Given::InvalidThenError, /multiple.*statements/i) }
    end

  end
end
