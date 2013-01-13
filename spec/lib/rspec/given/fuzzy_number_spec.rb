require 'spec_helper'

describe RSpec::Given::Fuzzy::FuzzyNumber do
  use_natural_assertions
  include RSpec::Given::Fuzzy

  Given(:delta) { 0.0001 }
  Given(:number) { about(10, delta) }

  context "when exact match" do
    Then { 10 == number }
    Then { number == 10 }
  end

  context "when (barely) in range" do
    Then { (10 + 0.0001) == number }
    Then { (10 - 0.0001) == number }
  end

  context "when out of range" do
    Then { (10 + 0.000100001) != number }
    Then { (10 - 0.000100001) != number }
  end

  describe "default delta" do
    N = 10
    HI_IN_RANGE = 1 + N*Float::EPSILON
    LO_IN_RANGE = 1 - N*Float::EPSILON
    HI_OUT_OF_RANGE = 1 + (N+1)*Float::EPSILON
    LO_OUT_OF_RANGE = 1 - (N+1)*Float::EPSILON

    Given(:number) { about(exact_number) }

    Invariant { exact_number*HI_IN_RANGE == number }
    Invariant { exact_number*LO_IN_RANGE == number }

    Invariant { exact_number*HI_OUT_OF_RANGE != number }
    Invariant { exact_number*LO_OUT_OF_RANGE != number }

    context "when 1" do
      Given(:exact_number) { 1 }
      Then { exact_number == number }
    end

    context "when rather large" do
      Given(:exact_number) { 1_000_000 }
      Then { exact_number == number }
    end

    context "when rather small" do
      Given(:exact_number) { 0.000_001 }
      Then { exact_number == number }
    end
  end

  describe "#to_s" do
    Then { number.to_s == "<Approximately 10 +/- 0.0001>" }
  end
end
