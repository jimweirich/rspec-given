# rspec-given

Covering rspec-given, version 1.5.0.

rspec-given is an RSpec extension to allow Given/When/Then notation in
RSpec specifications.  It is a natural extension of the experimental
work done on the Given framework.  It turns out that 90% of the Given
framework can be trivially implemented on top of RSpec.

# Why Given/When/Then

RSpec has done a great job of making specifications more readable for
humans.  However, I really like the given / when / then nature of
Cucumber stories and would like to follow the same structure in my
unit tests.  rspec-given allows a simple given/when/then structure
RSpec specifications.

## Status

_rspec-given_ is ready for production use.

## Example

Here is a specification written in the rspec-given framework:

<pre>
require 'rspec/given'
require 'spec_helper'
require 'stack'

describe Stack do
  def stack_with(initial_contents)
    stack = Stack.new
    initial_contents.each do |item| stack.push(item) end
    stack
  end

  Given(:stack) { stack_with(initial_contents) }

  context "when empty" do
    Given(:initial_contents) { [] }
    Then { stack.depth.should == 0 }

    context "when pushing" do
      When { stack.push(:an_item) }

      Then { stack.depth.should == 1 }
      Then { stack.top.should == :an_item }
    end
  end

  context "with one item" do
    Given(:initial_contents) { [:an_item] }

    context "when popping" do
      When(:pop_result) { stack.pop }

      Then { pop_result.should == :an_item }
      Then { stack.should be_empty }
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
</pre>

Let's talk about the individual statements used in the Given
framework.

### Given

The _Given_ section specifies a starting point, a set of preconditions
that must be true before the code under test is allowed to be run.  In
standard test frameworks the preconditions are established with a
combination of setup methods (or :before actions in RSpec) and code in
the test.

In the example code above the preconditions are started with _Given_
statements.  A top level _Given_ (that applies to the entire describe
block) says that one of the preconditions is that there is a stack
with some initial contents.

Note that initial contents are not specified in the top level describe
block, but are given in each of the nested contexts.  By pushing the
definition of "initial_contents" into the nested contexts, we can vary
them as needed for that particular context.

A precondition in the form "Given(:var) {...}" creates an accessor
method named "var".  The accessor is lazily initialized by the code
block.  If you want a non-lazy given, use "Given!(:var) {...}".

A precondition in the form "Given {...}" just executes the code block
for side effects.  Since there is no accessor, the code block is
executed immediately (i.e. no lazy evaluation).

The preconditions are run in order of definition.  Nested contexts
will inherit the preconditions from the enclosing context, with out
preconditions running before inner preconditions.

#### Given examples:

<pre>
    Given(:stack) { Stack.new }
</pre>

The given block is lazily run if 'stack' is ever referenced in the
test and the value of the block is bound to 'stack'.  The first
reference to 'stack' in the specification will cause the code block to
execute.  Futher references to 'stack' will reuse the previously
generated value.

<pre>
    Given!(:original_size) { stack.size }
</pre>

The code block is run unconditionally once before each test and the
value of the block is bound to 'original_size'.  This form is useful
when you want to record the value of something that might be affected
by the When code.

<pre>
    Given { stack.clear }
</pre>

The given block is run unconditionally once before each test.  This
form of given is used for code that is executed for side effects.

### When

The _When_ block specifies the code to be tested ... oops, excuse me
... specified.  After the preconditions in the given section are met,
the when code block is run.

There should only be one _When_ block for a given context. However, a
_When_ in an outer context shoud be treated as a _Given_ in an inner
context.  E.g.

<pre>
    context "outer context" do
      When { code specified in the outer context }
      Then { assert something about the outer context }

      context "inner context" do

        # At this point, the _When_ of the outer context
        # should be treated as a _Given_ of the inner context

        When { code specified in the inner context }
        Then { assert something about the inner context }
      end
    end
</pre>

#### When examples:

<pre>
    When { stack.push(:item) }
</pre>

The code block is executed once per test.  The effect of the _When{}_
block is very similar to _Given{}_.  However, When is used to identify
the particular code that is being specified in the current context or
describe block.

<pre>
    When(:result) { stack.pop }
</pre>

The code block is executed once per test and the value of the code
block is bound to 'result'.  Use this form when the code under test
returns a value that you wish to interrogate in the _Then_ code.

### Then

The _Then_ sections are the postconditions of the specification. These
then conditions must be true after the code under test (the _When_
block) is run.

The code in the _Then_ block should be a single _should_
assertion. Code in _Then_ blocks should not have any side effects.

#### Then examples:

<pre>
    Then { stack.should be_empty }
</pre>

After the related _When_ block is run, the stack should be empty.  If
it is not empty, the test will fail.

<!--
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

-->

# Future Directions

I really like the way the Given framework is working out.  I feel my
tests are much more like specifications when I use it.  However, I'm
not entirely happy with it.

First, I would like to introduce invariants.  An _Invariant_ block
would essentially be a post-conditions that should be true after
_Then_ block in the same (or nested) context as the invariant.

Second, I would like to remove the need for the ".should" in all the
_Then_ blocks.  In other words, instead of saying:

    Then { x.should == y }

we could say:

    Then { x == y }

I think the [wrong assertion library](http://rubygems.org/gems/wrong)
has laid some groundwork in this area.

# Links

* Github: [https://github.com/jimweirich/rspec-given](https://github.com/jimweirich/rspec-given)
* Clone URL: git://github.com/jimweirich/rspec-given.git
* Bug/Issue Reporting: [http://onestepback.org/cgi-bin/bugs.cgi?project=rspec-given](http://onestepback.org/cgi-bin/bugs.cgi?project=rspec-given)

