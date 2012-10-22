# rspec-given

Covering rspec-given, version 2.1.0.

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

```ruby
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
```

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

```ruby
    Given(:stack) { Stack.new }
```

The block for the given clause is lazily run if 'stack' is ever
referenced in the test and the value of the block is bound to 'stack'.
The first reference to 'stack' in the specification will cause the
code block to execute. Futher references to 'stack' will reuse the
previously generated value.

```ruby
    Given!(:original_size) { stack.size }
```

The code block is run unconditionally once before each test and the
value of the block is bound to 'original_size'.  This form is useful
when you want to record the value of something that might be affected
by the When code.

```ruby
    Given { stack.clear }
```

The block for the given clause is run unconditionally once before each
test. This form of given is used for code that is executed for side
effects.

### When

The _When_ clause specifies the code to be tested ... oops, excuse me
... specified.  After the preconditions in the given section are met,
the when code block is run.

In general there should not be more than one _When_ clause for a given
direct context. However, a _When_ in an outer context will be run
after all the _Givens_ but before the inner _When_. You can think of
an outer _When_ as setting up additional given state for the inner
_When_.

E.g.

```ruby
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
```

#### When examples:

```ruby
    When { stack.push(:item) }
```

The code block is executed once per test.  The effect of the _When{}_
block is very similar to _Given{}_.  However, When is used to identify
the particular code that is being specified in the current context or
describe block.

```ruby
    When(:result) { stack.pop }
```

The code block is executed once per test and the value of the code
block is bound to 'result'.  Use this form when the code under test
returns a value that you wish to interrogate in the _Then_ code.

If an exception occurs during the execution of the block for the When
clause, the exception is caught and a failure object is bound to
'result'. The failure can be checked in a then block with the
'have_failed' matcher.

The failure object will rethrow the captured exception if anything
other than have_failed matcher is used on the failure object.

For example, if the stack is empty when it is popped, then it is
reasonable for pop to raise an UnderflowError. This is how you might
specify that behavior:

```ruby
    When(:result) { stack.pop }
    Then { result.should have_failed(UnderflowError, /empty/) }
```

Note that the arguments to the 'have_failed' matcher are the same as
those given to the standard RSpec matcher 'raise_error'.

### Then

The _Then_ clauses are the postconditions of the specification. These
then conditions must be true after the code under test (the _When_
clause) is run.

The code in the block of a _Then_ clause should be a single _should_
assertion. Code in _Then_ clauses should not have any side effects.

Let me repeat that: <b>_Then_ clauses should not have any side
effects!</b> _Then_ clauses with side effects are erroneous. _Then_
clauses need to be idempotent, so that running them once, twice, a
hundred times, or never does not change the state of the program. (The
same is true of _And_ clauses).

In RSpec terms, a _Then_ clause forms a RSpec Example that runs in the
context of an Example Group (defined by a describe or context clause).

Each Example Group must have at least one _Then_ clause, otherwise
there will be no examples to be run for that group. If all the
assertions in an example group are done via Invariants, then the group
should use an empty _Then_ clause, like this:

```ruby
    Then { }
```

#### Then examples:

```ruby
    Then { stack.should be_empty }
```

After the related block for the _When_ clause is run, the stack should
be empty. If it is not empty, the test will fail.

### And

The _And_ clause is similar to _Then_, but does not form its own RSpec
example. This means that _And_ clauses reuse the setup from a sibling
_Then_ clause. Using a single _Then_ an multiple _And_ clauses in an
example group means the setup for that group is run only once (for the
_Then_ clause) and reused for all the _And_s. This can be a
significant speed savings where the setup for an example group is
expensive.

Some things to keep in mind about _And_ clauses:

1. There must be at least one _Then_ in the example group and it must
   be declared before the _And_ clauses. Forgetting the _Then_ clause
   is an error.

1. The code in the _And_ clause is run immediately after the first
   (executed) _Then_ of an example group.

1. And assertion failures in a _Then_ clause or a _And_ clause will
   cause all the subsequent _And_ clauses to be skipped.

1. Since _And_ clauses do not form their own RSpec examples, they are
   not represented in the formatted output of RSpec. That means _And_
   clauses do not produce dots in the Progress format, nor do they
   appear in the documentation, html or textmate formats (options
   -fhtml, -fdoc, or -ftextmate).

1. Like _Then_ clauses, _And_ clauses must be idempotent. That means
   they should not execute any code that changes global program state.
   (See the section on the _Then_ clause).

The choice to use an _And_ clause is primarily a speed consideration.
If an example group has expensive setup and there are a lot of _Then_
clauses, then choosing to make some of the _Then_ clauses into _And_
clause will speed up the spec. Otherwise it is probably better to
stick with _Then_ clauses.

#### Then/And examples:

```ruby
  Then { pop_result.should == :top_item }           # Required
  And  { stack.top.should == :second_item }         # No Setup rerun
  And  { stack.depth.should == original_depth - 1 } # ... for these
```

### Invariant

The _Invariant_ clause is a new idea that doesn't have an analog in
RSpec or Test::Unit. The invariant allows you specify things that must
always be true in the scope of the invariant. In the stack example,
<tt>empty?</tt> is defined in term of <tt>size</tt>. Whenever
<tt>size</tt> is 0, <tt>empty?</tt> should be true. Whenever
<tt>size</tt> is non-zero, <tt>empty?</tt> should be false.

You can conceptually think of an _Invariant_ clause as a _Then_ block
that automatically gets added to every _Then_ within its scope.

Invariants nested within a context only apply to the _Then_ clauses
that are in the scope of that context.

Invariants that reference a _Given_ precondition accessor must only be
used in contexts that define that accessor.

Notes:

1. Since Invariants do not form their own RSpec example, they are not
   represented in the RSpec formatted output (e.g. the '--format html'
   option).

## Configuration

Just require 'rspec/given' in the spec helper of your project and it
is ready to go.

If the RSpec format option document, html or textmate are chosen,
RSpec/Given will automatically add addition source code information to
the examples to produce better looking output. If you don't care about
the pretty output and wish to disable source code caching
unconditionally, then add the following line to your spec helper file:

```ruby
    RSpec::Given.source_caching_disabled = true
```

# Future Directions

I really like the way the Given framework is working out.  I feel my
tests are much more like specifications when I use it.  However, I'm
not entirely happy with it.

I would like to remove the need for the ".should" in all the _Then_
clauses. In other words, instead of saying:

```ruby
    Then { x.should == y }
```

we could say:

```ruby
    Then { x == y }
```

I think the [wrong assertion library](http://rubygems.org/gems/wrong)
has laid some groundwork in this area.

# Links

* Github: [https://github.com/jimweirich/rspec-given](https://github.com/jimweirich/rspec-given)
* Clone URL: git://github.com/jimweirich/rspec-given.git
* Bug/Issue Reporting: [https://github.com/jimweirich/rspec-given/issues](https://github.com/jimweirich/rspec-given/issues)
* Continuous Integration: [http://travis-ci.org/#!/jimweirich/rspec-given](http://travis-ci.org/#!/jimweirich/rspec-given)
