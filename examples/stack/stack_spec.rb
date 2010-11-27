require 'spec_helper'
require 'stack'

describe Stack do
  # NOTE: Invariants are not yet supported in rspec-given
  # Invariant { stack.depth >= 0 }
  # Invariant { stack.empty? == (stack.depth == 0) }

  Given(:empty_stack) { Stack.new }

  def a_stack_with_one_item
    stack = Stack.new
    stack.push(:an_item)
    stack
  end

  def a_stack_with_several_items
   stack = Stack.new
   stack.push(:second_item)
   stack.push(:top_item)
   stack
  end

  context "an empty stack" do
    Given(:stack) { Stack.new }

    Then { stack.depth.should == 0 }

    context "Pushing onto an empty stack" do
      When { stack.push(:an_item) }

      Then { stack.depth.should == 1 }
      Then { stack.top.should == :an_item }
    end
  end

  context "a stack with one item do" do
    Given(:stack) { a_stack_with_one_item }

    context "popping an item empties the stack" do
      When(:pop_result) { stack.pop }

      Then { pop_result.should == :an_item }
      Then { stack.should be_empty }
    end
  end

  context "a stack with several items" do
    Given(:stack) { a_stack_with_several_items }
    Given!(:original_depth) { stack.depth }

    context "pushing a new item adds a new top" do
      When { stack.push(:new_item) }

      Then { stack.top.should == :new_item }
      Then { stack.depth.should == original_depth + 1 }
    end

    context "popping an item removes the top item" do
      When(:pop_result) { stack.pop }

      Then { pop_result.should == :top_item }
      Then { stack.top.should == :second_item }
      Then { stack.depth.should == original_depth - 1 }
    end
  end
end
