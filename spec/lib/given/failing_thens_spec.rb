require 'spec_helper'

describe "Failing Then clauses" do

  # NOTE: FAIL and ERROR are special versions of the Then clause that
  # expect failures and errors. These are used only in the framework
  # testing and are not generally available.

  context "with false" do
    FAIL { false }
  end

  context "with exception comparison in when result" do
    When(:result) { fail "explicitly" }
    ERROR { result == 1 }
  end

  context "with bare exception in when result" do
    When(:result) { fail "explicitly" }
    ERROR { result }
  end

end
