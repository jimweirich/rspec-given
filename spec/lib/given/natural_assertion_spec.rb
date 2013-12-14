require 'rspec/given'
require 'spec_helper'

describe Given::NaturalAssertion do
  before do
    pending "Natural Assertions disabled for JRuby" unless Given::NATURAL_ASSERTIONS_SUPPORTED
  end

  describe "#content?" do
    context "with empty block" do
      FauxThen { }
      Then { expect(na).to_not have_content }
    end
    context "with block returning false" do
      FauxThen { false }
      Then { expect(na).to have_content }
    end
  end

  describe "passing criteria" do
    context "with true" do
      FauxThen { true }
      Then { _gvn_block_passed?(faux_block) }
    end

    context "with false" do
      FauxThen { false }
      Then { ! _gvn_block_passed?(faux_block) }
    end

    context "with to_bool/true" do
      Given(:res) { double(:to_bool => true) }
      FauxThen { res }
      Then { _gvn_block_passed?(faux_block) }
    end

    context "with to_bool/false" do
      Given(:res) { double(:to_bool => false) }
      FauxThen { res }
      Then { ! _gvn_block_passed?(faux_block) }
    end
  end

  describe "failure messages" do
    let(:msg) { na.message }
    Invariant { expect(msg).to match(/^FauxThen expression/) }

    context "with equals assertion" do
      Given(:a) { 1 }
      FauxThen { a == 2 }
      Then { expect(msg).to match(/\bexpected: +1\b/) }
      Then { expect(msg).to match(/\bto equal: +2\b/) }
      Then { expect(msg).to match(/\bfalse +<- +a == 2\b/) }
      Then { expect(msg).to match(/\b1 +<- +a\b/) }
    end

    context "with equals assertion with do/end" do
      Given(:a) { 1 }
      FauxThen do a == 2 end
      Then { expect(msg).to match(/\bexpected: +1\b/) }
      Then { expect(msg).to match(/\bto equal: +2\b/) }
      Then { expect(msg).to match(/\bfalse +<- +a == 2\b/) }
      Then { expect(msg).to match(/\b1 +<- +a\b/) }
    end

    context "with not-equals assertion" do
      Given(:a) { 1 }
      FauxThen { a != 1 }
      Then { expect(msg).to match(/\bexpected: +1\b/) }
      Then { expect(msg).to match(/\bto not equal: +1\b/) }
      Then { expect(msg).to match(/\bfalse +<- +a != 1\b/) }
      Then { expect(msg).to match(/\b1 +<- +a\b/) }
    end

    context "with less than assertion" do
      Given(:a) { 1 }
      FauxThen { a < 1 }
      Then { expect(msg).to match(/\bexpected: +1\b/) }
      Then { expect(msg).to match(/\bto be less than: +1\b/) }
      Then { expect(msg).to match(/\bfalse +<- +a < 1\b/) }
      Then { expect(msg).to match(/\b1 +<- +a\b/) }
    end

    context "with less than or equal to assertion" do
      Given(:a) { 1 }
      FauxThen { a <= 0 }
      Then { expect(msg).to match(/\bexpected: +1\b/) }
      Then { expect(msg).to match(/\bto be less or equal to: +0\b/) }
      Then { expect(msg).to match(/\bfalse +<- +a <= 0\b/) }
      Then { expect(msg).to match(/\b1 +<- +a\b/) }
    end

    context "with greater than assertion" do
      Given(:a) { 1 }
      FauxThen { a > 1 }
      Then { expect(msg).to match(/\bexpected: +1\b/) }
      Then { expect(msg).to match(/\bto be greater than: +1\b/) }
      Then { expect(msg).to match(/\bfalse +<- +a > 1\b/) }
      Then { expect(msg).to match(/\b1 +<- +a\b/) }
    end

    context "with greater than or equal to assertion" do
      Given(:a) { 1 }
      FauxThen { a >= 3 }
      Then { expect(msg).to match(/\bexpected: +1\b/) }
      Then { expect(msg).to match(/\bto be greater or equal to: +3\b/) }
      Then { expect(msg).to match(/\bfalse +<- +a >= 3\b/) }
      Then { expect(msg).to match(/\b1 +<- +a\b/) }
    end

    context "with match assertion" do
      Given(:s) { "Hello" }
      FauxThen { s =~ /HI/ }
      Then { expect(msg).to match(/\bexpected: +"Hello"$/) }
      Then { expect(msg).to match(/\bto match: +\/HI\/$/) }
      Then { expect(msg).to match(/\bnil +<- +s =~ \/HI\/$/) }
      Then { expect(msg).to match(/"Hello" +<- +s$/) }
    end

    context "with not match assertion" do
      Given(:s) { "Hello" }
      FauxThen { s !~ /Hello/ }
      Then { expect(msg).to match(/\bexpected: +"Hello"$/) }
      Then { expect(msg).to match(/\bto not match: +\/Hello\/$/) }
      Then { expect(msg).to match(/\bfalse +<- +s !~ \/Hello\/$/) }
      Then { expect(msg).to match(/"Hello" +<- +s$/) }
    end

    context "with exception" do
      Given(:ary) { nil }
      FauxThen { ary[1] == 3 }
      Then { expect(msg).to match(/\bexpected: +NoMethodError/) }
      Then { expect(msg).to match(/\bto equal: +3$/) }
      Then { expect(msg).to match(/\bNoMethodError.+NilClass\n +<- +ary\[1\] == 3$/) }
      Then { expect(msg).to match(/\bNoMethodError.+NilClass\n +<- +ary\[1\]$/) }
      Then { expect(msg).to match(/\bnil +<- +ary$/) }
    end

    context "with value with newlines" do
      class FunkyInspect
        def inspect
          "XXXX\nYYYY"
        end
        def ok?
          false
        end
      end
      Given(:zzzz) { FunkyInspect.new }
      FauxThen { zzzz.ok? }
      Then { expect(msg).to match(/\n  false   <- zzzz\.ok\?/) }
      Then { expect(msg).to match(/\n  XXXX\n/) }
      Then { expect(msg).to match(/\n  YYYY\n/) }
      Then { expect(msg).to match(/\n          <- zzzz$/) }
    end
  end

  describe "bad Then blocks" do
    context "with no statements" do
      FauxThen {  }
      When(:result) { na.message }
      Then { expect(result).to_not have_failed }
    end

    context "with multiple statements" do
      FauxThen {
        ary = nil
        ary[1] == 3
      }
      When(:result) { na.message }
      Then { expect(result).to have_failed(Given::InvalidThenError, /multiple.*statements/i) }
    end

  end
end
