require 'rspec/given'
require 'example_helper'
require 'stack'

describe Stack do
  def stack_with(initial_contents)
    stack = Stack.new
    initial_contents.each do |item| stack.push(item) end
    stack
  end

  Given(:stack) { stack_with(initial_contents) }
  Invariant { stack.empty?.should == (stack.depth == 0) }

  context "when empty" do
    Given(:initial_contents) { [] }
    Then { stack.depth.should == 0 }

    context "when pushing" do
      When { stack.push(:an_item) }

      Then { stack.depth.should == 1 }
      Then { stack.top.should == :an_item }
    end

    context "when popping" do
      When(:result) { stack.pop }
      Then { result.should have_failed(Stack::UnderflowError, /empty/) }
    end
  end

  context "with one item" do
    Given(:initial_contents) { [:an_item] }

    context "when popping" do
      When(:pop_result) { stack.pop }

      Then { pop_result.should == :an_item }
      Then { stack.depth.should == 0 }
    end
  end

  context "with several items" do
    Given(:initial_contents) { [:second_item, :top_item] }
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
