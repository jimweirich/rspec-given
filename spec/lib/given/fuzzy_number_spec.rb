require 'spec_helper'

describe Given::Fuzzy::FuzzyNumber do
  use_natural_assertions_if_supported
  include Given::Fuzzy

  describe "attributes" do
    Given(:number) { about(10).delta(0.0001) }
    Then { number.exact_value == 10 }
    Then { number.delta_amount == 0.0001 }
    Then { number.low_limit == (10 - 0.0001) }
    Then { number.high_limit == (10 + 0.0001) }
  end

  describe "#exactly_equals?" do
    Given(:number) { about(10).delta(0.0001) }
    Given(:same_number) { about(10).delta(0.0001) }
    Given(:different_delta) { about(10).delta(0.001) }
    Given(:different_exact) { about(11).delta(0.0001) }

    Then { number.exactly_equals?(number) }
    Then { number.exactly_equals?(same_number) }

    Then { ! number.exactly_equals?(different_exact) }
    Then { ! number.exactly_equals?(different_delta) }
  end

  describe "fixed deltas" do
    Given(:exact_number) { 10 }
    Given(:number) { about(exact_number).delta(0.001) }

    Then { exact_number == number }

    Then { (exact_number + 0.001) == number }
    Then { (exact_number - 0.001) == number }

    Then { (exact_number + 0.001001) != number }
    Then { (exact_number - 0.001001) != number }
  end

  describe "negative deltas" do
    Given(:exact_number) { 10 }
    Given(:number) { about(exact_number).delta(-0.001) }

    Then { exact_number == number }

    Then { (exact_number + 0.001) == number }
    Then { (exact_number - 0.001) == number }

    Then { (exact_number + 0.001001) != number }
    Then { (exact_number - 0.001001) != number }
  end

  describe "percentage deltas" do
    Given(:exact_number) { 1 }
    Given(:number) { about(exact_number).percent(25) }

    Then { exact_number == number }

    Then { (exact_number + 0.25) == number }
    Then { (exact_number - 0.25) == number }

    Then { (exact_number + 0.25001) != number }
    Then { (exact_number - 0.25001) != number }
  end

  describe "epsilon deltas" do
    Given(:neps) { 10 }
    Given(:hi_in_range) { 1 + neps*Float::EPSILON }
    Given(:lo_in_range) { 1 - neps*Float::EPSILON }
    Given(:hi_out_of_range) { 1 + (neps+1)*Float::EPSILON }
    Given(:lo_out_of_range) { 1 - (neps+1)*Float::EPSILON }

    Invariant { exact_number*hi_in_range == number }
    Invariant { exact_number*lo_in_range == number }

    Invariant { exact_number*hi_out_of_range != number }
    Invariant { exact_number*lo_out_of_range != number }

    context "when created with default delta" do
      Given(:number) { about(exact_number) }

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

    context "when created with small epsilon" do
      Given(:neps) { 100 }
      Given(:exact_number) { 10 }
      Given(:number) { about(exact_number).epsilon(neps) }
      Then { exact_number == number }
    end
  end

  describe "#to_s" do
    Given(:number) { about(10).delta(0.0001) }
    Then { number.to_s == "<Approximately 10 +/- 0.0001>" }
  end
end
