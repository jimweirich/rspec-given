require 'spec_helper'
require 'stack'

describe Stack do
  # NOTE: Invariants are not yet supported in rspec-given
  # Invariant { stack.depth >= 0 }
  # Invariant { stack.empty? == (stack.depth == 0) }

  Given(:stack) { Stack.new }

  context "when empty" do
    Then { stack.depth.should == 0 }

    context "when pushing" do
      When { stack.push(:an_item) }

      Then { stack.depth.should == 1 }
      Then { stack.top.should == :an_item }
    end
  end

  context "with one item" do
    Given { stack.push(:an_item) }

    context "when popping" do
      When(:pop_result) { stack.pop }

      Then { pop_result.should == :an_item }
      Then { stack.should be_empty }
    end
  end

  context "with several items" do
    Given {
      stack.push(:second_item)
      stack.push(:top_item)
    }
    Given!(:original_depth) { stack.depth }

    context "when pushing" do
      When { stack.push(:new_item) }

      Then { stack.top.should == :new_item }
      Then { stack.depth.should == original_depth + 1 }
    end

    context "when popping" do
      When(:pop_result) { stack.pop }

      Then { pop_result.should == :top_item }
      Then { stack.top.should == :second_item }
      Then { stack.depth.should == original_depth - 1 }
    end
  end
end
