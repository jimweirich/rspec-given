# rspec-given

rspec-given is an RSpec 2 extension to allow Given/When/Then notation
in RSpec specifications.  It is a natural extension of the
experimental work done on the Given framework.  It turns out that 90%
of the Given framework can be trivially implemented on top of RSpec.

# Why Given/When/Then

RSpec has done a great job of making specifications more readable for
humans.  However, I really like the given / when / then nature of
Cucumber stories and would like to follow the same structure in my
unit tests.  rspec-given allows a simple given/when/then structure
RSpec specifications.

## Status

rspec-given is quite usable at the moment, although is is lacking
several features.

* Invariants are not supported yet.
* Then assertions without _should_ are not supported yet.

## Example Zero

Here's the spec that I've been playing with.  Its gone through
mulitple revisions and several prototype implementations.  And this is
probably not the final form.

With all that in mind, here's a specification in my imaginary
framework:

<pre>
require 'spec_helper'
require 'stack'

describe Stack do
  # NOTE: Invariants are not yet supported in rspec-given
  # Invariant { stack.depth >= 0 }
  # Invariant { stack.empty? == (stack.depth == 0) }

  Given(:an_empty_stack) { Stack.new }

  Given(:a_stack_with_one_item) do
    Stack.new.tap do |s|
      s.push(:an_item)
    end
  end

  Given(:a_stack_with_several_items) do
    Stack.new.tap do |s|
      s.push(:second_item)
      s.push(:top_item)
    end
  end

  context "an empty stack" do
    Given(:stack) { an_empty_stack }

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
</pre>

Let's talk about the individual sections.

### Given

The _Given_ section specifies a starting point, a set of preconditions
that must be true before the code under test is allowed to be run.  In
standard test frameworks the preconditions are established with a
combination of setup methods (or :before actions in RSpec) and code in
the test.

In the example code above, we see three starting points of interest.
One is an empty, just freshly created stack.  The next is a stack with
exactly one item.  The final starting point is a stack with several
items.

A precondition in the form "Given(:var) {...}" creates an accessor
method named "var".  The accessor is lazily initialized by the code
block.  If you want a non-lazy given, use "Given!(:var) {...}".

A precondition in the form "Given {...}" just executes the code block
for side effects.  Since there is no accessor, the code block is
executed immediately (i.e. no lazy evaluation).

The preconditions are run in order of definition.  Nested contexts
will inherit the preconditions from the enclosing context, with out
preconditions running before inner preconditions.

### When

The _When_ block specifies the code to be tested ... oops, excuse me
... specified.  After the preconditions in the given section are met,
the when code block is run.

There should only be one _When_ block for a given context.

### Then

The _Then_ sections are the postconditions of the specification. These
then conditions must be true after the code under test (the _When_
block) is run.

The code in the _Then_ block should be a single boolean condition that
devaluates to true if the code in the _When_ block is correct.  If the
_Then_ block evaluates to false, then that is recorded as a failure.

### Invariant

The _Invariant_ block is a new idea that doesn't have an analog in
RSpec or Test::Unit.  The invariant allows you specify things that
must always be true.  In the stack example, <tt>empty?</tt> is defined
in term of <tt>size</tt>.  Whenever <tt>size</tt> is 0,
<tt>empty?</tt> should be true.  Whenever <tt>size</tt> is non-zero,
<tt>empty?</tt> should be false.

You can conceptually think of an _Invariant_ block as a _Then_ block
that automatically gets added to every _When_ within its scope.

Invariants nested within a context only apply to the _When_ blocks in
that context.  

Invariants that reference a _Given_ precondition accessor must only be
used in contexts that define that accessor.

NOTE: Invariants are not yet implemented in the current version of
rspec-given.
