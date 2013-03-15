# rspec-given

| Master |
| :----: |
| [![Master Build Status](https://secure.travis-ci.org/jimweirich/rspec-given.png?branch=master)](https://travis-ci.org/jimweirich/rspec-given) |

Covering rspec-given, version 2.4.1.

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

rspec-given is ready for production use.

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

  context "with no items" do
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
will inherit the preconditions from the enclosing context, with outer
preconditions running before inner preconditions.

#### Given examples:

```ruby
    Given(:stack) { Stack.new }
```

The block for the given clause is lazily run and its value bound to
'stack' if 'stack' is ever referenced in the test.
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
same is true of _And_ and _Invariant_ clauses).

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
_Then_ clause. Using a single _Then_ and multiple _And_ clauses in an
example group means the setup for that group is run only once (for the
_Then_ clause) and reused for all the _And_ clauses. This can be a
significant speed savings where the setup for an example group is
expensive.

Some things to keep in mind about _And_ clauses:

* There must be at least one _Then_ in the example group and it must
  be declared before the _And_ clauses. Forgetting the _Then_ clause
  is an error.

* The code in the _And_ clause is run immediately after the first
  (executed) _Then_ of an example group.

* An assertion failure in a _Then_ clause or an _And_ clause will
  cause all the subsequent _And_ clauses to be skipped.

* Since _And_ clauses do not form their own RSpec examples, they are
  not represented in the formatted output of RSpec. That means _And_
  clauses do not produce dots in the Progress format, nor do they
  appear in the documentation, html or textmate formats (options
  -fhtml, -fdoc, or -ftextmate).

* Like _Then_ clauses, _And_ clauses must be idempotent. That means
  they should not execute any code that changes global program state.
  (See the section on the _Then_ clause).

The choice to use an _And_ clause is primarily a speed consideration.
If an example group has expensive setup and there are a lot of _Then_
clauses, then choosing to make some of the _Then_ clauses into _And_
clauses will speed up the spec. Otherwise it is probably better to
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
always be true in the scope of the invariant. In the stack example, the method
<tt>empty?</tt> is defined in term of <tt>size</tt>.

```ruby
  Invariant { stack.empty? == (stack.depth == 0) }
```

This invariant states that <code>empty?</code> is true if and only if
the stack depth is zero, and that assertion is checked at every _Then_
clause that is in the same scope.

You can conceptually think of an _Invariant_ clause as a _Then_ block
that automatically gets added to every _Then_ within its scope.
Invariants nested within a context only apply to the _Then_ clauses
that are in the scope of that context.

Invariants that reference a _Given_ precondition accessor must only be
used in contexts that define that accessor.

Notes:

* Since Invariants do not form their own RSpec example, they are not
  represented in the RSpec formatted output (e.g. the '--format html'
  option).

## Execution Ordering

When running the test for a specific _Then_ clause, the following will
be true:

* The non-lazy _Given_ clauses will be run in the order that they are
  specified, from the outermost scope to the innermost scope
  containing the _Then_. (The lazy _Given_ clauses will be run upon
  demand).

* All of the _Given_ clauses in all of the relevant scopes will run
  before the first (outermost) _When_ clause in those same scopes.
  That means that the _When_ code can assume that the givens have been
  established, even if the givens are in a more nested scope than the
  When.

* _When_ clauses and RSpec _before_ blocks will be executed in the
  order that they are specified, from the outermost block to the
  innermost block. This makes _before_ blocks an excellent choice when
  writing narrative tests to specify actions that happen between the
  "whens" of a narrative-style test.

Note that the ordering between _Given_ clauses and _before_ blocks are
not strongly specified. Hoisting a _When_ clause out of an inner scope
to an outer scope may change the order of execution between related
_Given_ clauses and any _before_ blocks (hoisting the _When_ clause
might cause the related _Given_ clauses to possibly run earlier).
Because of this, do not split order dependent code between _Given_
clauses and _before_ blocks.

## Natural Assertions

**NOTE:** <em>Natural assertions are currently an experimental feature
of RSpec/Given. They are currently disabled by default, but can be
enabled by a simple configuration option (see "use_natural_assertions"
below).</em>

RSpec/Given now supports the use of "natural assertions" in _Then_,
_And_, and _Invariant_ blocks. Natural assertions are just Ruby
conditionals, without the _should_ or _expect_ methods that RSpec
provides. Here are the Then/And examples from above, but written using
natural assertions:

```ruby
  Then { pop_result == :top_item }
  And  { stack.top == :second_item }
  And  { stack.depth == original_depth - 1 }
```

Natural assertions must be enabled, either globally or on a per
context basis, to be recognized.

Here's a heads up: If you use natural assertions, but fail to enable
them, all your specs will mysteriously pass. This is why the **red**
part of _Red/Green/Refactor_ is so important.

### Failure Messages with Natural Assertions

Since natural assertions do not depend upon matchers, you don't get
customized error messages from them. What you _do_ get is a complete
analsysis of the expression that failed.

For example, given the following failing specification:

```ruby
  RSpec::Given.use_natural_assertions

  describe "Natural Assertions" do
    Given(:foo) { 1 }
    Given(:bar) { 2 }
    Then { foo + bar == 2 }
  end
```

You would get:

```
  1) Natural Assertions
     Failure/Error: Then { foo + bar == 2 }
       Then expression failed at /Users/jim/working/git/rspec-given/examples/failing/sample_spec.rb:6
       expected: 3
       to equal: 2
         false   <- foo + bar == 2
         3       <- foo + bar
         1       <- foo
         2       <- bar
     # ./examples/failing/sample_spec.rb:6:in `block in Then'
```

Notice how the failing expression "<code>foo+bar == 2</code>" was
broken down into subexpressions and values for each subexpression.
This gives you all the information you need to figure out exactly what
part of the expression is causing the failure.

Natural assertions will give additional information (e.g. "expected:
3 to equal: 2") for top level expressions involving any of the
comparison operators (==, !=, <, <=, >, >=) or matching operators (=~,
!~).

### Caveats on Natural Assertions

Keep the following in mind when using natural assertions.

* Only a single expression/assertion per _Then_. The single expression
  of the _Then_ block will be considered when determining pass/fail
  for the assertion. If you _want_ to express a complex condition for
  the _Then_, you need to use ||, && or some other logical operation
  to join the conditions into a single expression (and the failure
  message will break down the values for each part).

* Then clauses need be **idempotent**. This is true in general, but it
  is particularly important for natural assertions to obey this
  restriction. This means that assertions in a Then clause should not
  change anything. Since the Natural Assertion error message contains
  the values of all the subexpressions, the expression and its
  subexpressions will be evaluated multiple times. If the Then clause
  is not idempotent, you will get changing answers as the
  subexpressions are evaluated.

That last point is important. If you write code like this:

```ruby
  # DO NOT WRITE CODE LIKE THIS
  context "Incorrect non-idempotent conditions" do
    Given(:ary) { [1, 2, 3] }
    Then { ary.delete(1) == nil }
  end
```

Then the assertion will fail (because <code>ary.delete(1)</code> will
initially return 1). But when the error message is formated, the
system reports that <code>ary.delete(1)</code> returns nil. You will
scratch your head over that for a good while.

Instead, move the state changing code into a _When(:result)_ block, then
assert what you need to about :result. Something
like this is good:

```ruby
  context "Correct idempotent conditions" do
    Given(:ary) { [1, 2, 3] }
    When(:result) { ary.delete(1) }
    Then { result == nil }
  end
```

It is good to note that non-idempotent assertions will also cause
problems with And clauses.

### Mixing Natural Assertions and RSpec Assertions

Natural assertions and RSpec assertions for the most part can be
intermixed in a single test suite, even within a single context.
Because there are a few corner cases that might cause problems, they
must be explicitly enabled before they will be considered.

To enable natural assertions in a context, call the
_use_natural_assertions_ method in that context. For example:

```ruby
  context "Outer" do
    use_natural_assertions

    context "Inner" do
    end

    context "Disabled" do
      use_natural_assertions false
    end
  end
```

Both the _Outer_ and _Inner_ contexts will use natural assertions. The
_Disabled_ context overrides the setting inherited from _Outer_ and
will not process natural assertions.

See the **configuration** section below to see how to enable natural
assertions project wide.

### Matchers and Natural Assertions

In RSpec, matchers are used to provide nice, readable error messages
when an assertion is not met. Natural assertions provide
self-explanatory failure messages for most things without requiring
any special matchers from the programmer.

In the rare case that some extra information would be helpful, it is
useful to create special objects that respond to the == operator.

#### Asserting Nearly Equal with Fuzzy Numbers

Operations on floating point numbers rarely create numbers that are
exactly equal, therefore it is useful to assert that two floating
point numbers are nearly equal. We do that by creating a fuzzy number
that has a looser interpretation of what it means to be equal.

For example, the following asserts that the square root of 10 is about
3.1523 with an accuracy of 1 percent.

```ruby
    Then { Math.sqrt(10) == about(3.1623).percent(1) }
```

As long as the real value of <code>Math.sqrt(10)</code> is within plus
or minus 1% of 3.1623 (i.e. 3.1623 +/- 0.031623), then the assertion
will pass.

There are several ways of creating fuzzy numbers:

* <code>about(n).delta(d)</code> -- A fuzzy number matching the range
  (n-d)..(n+d)

* <code>about(n).percent(p)</code> -- A fuzzy number matching the
  range (n-(n*p/100)) .. (n+(n*p/100))

* <code>about(n).epsilon(neps)</code> -- A fuzzy number matching the
  range (n-(neps*e)) .. (n+(neps*e)), where e is the difference
  between 1.0 and the next smallest floating point number.

* <code>about(n)</code> -- Same as <code>about(n).epsilon(10)</code>.

When the file <code>rspec/given/fuzzy_shortcuts</code> is required,
the following unicode shortcut methods are added to Numeric to create
fuzzy numbers.

* <code>n.±(del)</code> is the same as <code>about(n).delta(del)</code>

* <code>n.‰(percentage)</code> is the same as <code>about(n).percent(percentage)</code>

* <code>n.€(neps)</code> is the same as <code>about(n).epsilon(neps)</code>

* <code>n.±</code>, <code>n.‰</code>, and <code>n.€</code> are all
  the same as <code>about(n)</code>

#### Detecting Exceptions

The RSpec matcher used for detecting exceptions will work with natural
assertions out of the box. Just check for equality against the
<code>have_failed</code> return value.

For example, the following two Then clauses are equivalent:

```ruby
    # Using an RSpec matcher
    Then { result.should have_failed(StandardError, /message/) }

    # Using natural assertions
    Then { result == have_failed(StandardError, /message/) }
```

### Processing Natural Assertions

When natural assertions are enabled, they are only used if all of the
following are true:

1. The block does not throw an RSpec assertion failure (or any other
   exception for that matter).

1. The block returns false (blocks that return true pass the
   assertion and don't need a failure message).

1. The block does not use RSpec's _should_ or _expect_ methods.

Detecting that last point (the use of _should_ and _expect_) is done
by modifying the RSpec runtime to report uses of _should_ and
_expect_.

### Platform Support

Natural assertions use the Ripper library to parse the failing
condition and find all the sub-expression values upon a failure.
Currently Ripper is not supported on JRuby 1.7.2. Charles Nutter has
said that Ripper support is coming soon and may arrive as early as
version 1.7.3. Until then, natural assertions are disabled when
running under JRuby. Never fear, JRuby supports all the other features
of rspec-given and will work just fine.

### Further Reading

Natural assertions were inspired by the [wrong assertion
library](http://rubygems.org/gems/wrong) by [Alex
Chaffee](http://rubygems.org/profiles/alexch) and [Steve
Conover](http://rubygems.org/profiles/sconoversf).

## Configuration

Just require 'rspec/given' in the spec helper of your project and it
is ready to go.

If the RSpec format option document, html or textmate is chosen,
RSpec/Given will automatically add additional source code information to
the examples to produce better looking output. If you don't care about
the pretty output and wish to disable source code caching
unconditionally, then add the following line to your spec helper file:

```ruby
    RSpec::Given.source_caching_disabled = true
```

Natural assertions are disabled by default. To globally configure
natural assertions, add one of the following lines to your spec_helper
file:

```ruby
    RSpec::Given.use_natural_assertions         # Enable natural assertions
    RSpec::Given.use_natural_assertions true    # Same as above
    RSpec::Given.use_natural_assertions false   # Disable natural assertions
    RSpec::Given.use_natural_assertions :always # Always process natural assertions
                                                # ... even when should/expect are detected
```

# History

* Version 2.4.1

  * Fix bug where constants from nested modules were not properly
    accessed.

* Version 2.4.0

  * Add fuzzy number helper methods (with unicode method shortcuts).

  * Fix bug caused by blank lines in Thens.

# Links

* Github: [https://github.com/jimweirich/rspec-given](https://github.com/jimweirich/rspec-given)
* Clone URL: git://github.com/jimweirich/rspec-given.git
* Bug/Issue Reporting: [https://github.com/jimweirich/rspec-given/issues](https://github.com/jimweirich/rspec-given/issues)
* Continuous Integration: [http://travis-ci.org/#!/jimweirich/rspec-given](http://travis-ci.org/#!/jimweirich/rspec-given)
