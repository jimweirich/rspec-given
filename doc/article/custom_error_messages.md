## Beautiful Failure Messages

The RSpec/Given library is an extension to the RSpec testing framework
that explicitly supports a Given/When/Then style for testing.  It has
two goals:

* Encourage specification language when writing tests
* Allow beautiful failure messages without writing custom matchers

RSpec/Given has a been very successful in both these goals. Consider
the following spec snippet for a Page object in a Wiki Rails
application:

```ruby
describe "content conversion to HTML" do
  Given(:page) {
    Page.new(
      name: "HomePage",
      content: "Have a _nice_ day.")
  }
  Then { page.html_content == "Have a <em>nice</em> day." }
end
```

Assuming that the <code>html_content</code> method is incomplete and
not yet marking emphasized text, the failure message from the
specification will be:

    1) Page content conversion to HTML
       Failure/Error: Then { page.html_content == "Have a <em>nice</em> day." }
         Then expression failed at .../spec/models/page_spec.rb:38
         expected: "Have a _nice_ day."
         to equal: "Have a <em>nice</em> day."
           false   <- page.html_content == "Have a <em>nice</em> day."
           "Have a _nice_ day."
                    <- page.html_content
           #<Page name: "HomePage", content: "Have a _nice_ day." ...>
                   <- page
       # ./spec/models/page_spec.rb:38:in `block in Then'

Let's break that down:

**It says what failed:**

    Failure/Error: Then { page.html_content == "Have a <em>nice</em> day." }

**It says where it failed:**

    Then expression failed at .../spec/models/page_spec.rb:38

**It says what was expected:**

    expected: "Have a _nice_ day."
    to equal: "Have a <em>nice</em> day."

**It then breaks down each subexpression and displays its value:**

    false   <- page.html_content == "Have a <em>nice</em> day."
    "Have a _nice_ day."
            <- page.html_content
    #<Page name: "HomePage", content: "Have a _nice_ day." ...>
            <- page

All of this happens without the developer needing to write any special
error matchers or custom output.  Everything you need to debug a spec
failure is there in the output.

## A More Complex Example

Let's look at a more complex example.  Suppose we want to test
validations in the Page object.  For example, we might want to make
sure that:

* The page has a name
* The name conforms to the standard wiki naming convention (i.e. WikiName).

Here's the beginning of that specification:

```ruby
describe Page do
  VALID_ATTRS = { name: "SomePage", content: "CONTENT" }
  Given(:attrs) { VALID_ATTRS }
  Given(:page) { Page.new(attrs) }

...
end
```

<code>VALID\_ATTRS</code> is a list of attributes that will construct a
valid page object.  Normally I would put <code>VALID\_ATTRS</code> in something like
Factory Girl, but a simple constant is good enough this example.

I then declare a given that <code>attrs</code> is the valid
attributes, and that <code>Page</code> is constructed from these valid
attributes.

I can now describe a valid page object.

```ruby
  context "with valid attributes" do
    Then { page.valid? }
  end
```

To describe a validation failure where the name is missing, I create a
context where I override the default <code>attrs</code> with a version
that omits the name.

```ruby
context "with missing name" do
  Given(:attrs) { VALID_ATTRS.merge(name: nil) }
  Then { page.invalid? }
  And  { ! page.errors[:name].empty? }
  And  { page.errors[:name].any? { |msg| msg =~ /blank/ } }
end
```

Why Then/And/And? Because there are three things that should be true
if a validation fails.

1. The object must not be valid
2. The field that has the error must have error messages
3. At least one of the error messages should mention the word 'blank'

Suppose the Page object has a validation on name, but doesn't check
for presence.  The failure message clearly tells you that the spec
failed because no error messages on the <code>name</code> field
mentioned 'blank'.

    1) Page validations with missing name
       Failure/Error: Then { page.invalid? }
         And expression failed at ./spec/models/page_spec.rb:27
         Failing expression: And  { page.errors[:name].any? { |msg| msg =~ /blank/ } }
           false   <- page.errors[:name].any? { |msg| msg =~ /blank/ }
           ["is not a wiki name"]
                   <- page.errors[:name]
           #<ActiveModel::Errors:... @messages={:name=>["is not a wiki name"]}>
                   <- page.errors
           #<Page name: nil, content: "CONTENT", ...>
                   <- page
       # ./spec/models/page_spec.rb:25:in `block in Then'

We get informative error messages, which is exactly what we want.

However, the spec itself is a little wordy, with repeating
Then/And/And.  What if we wrote a simple query function that checked
for the three conditions and reported true/false accordingly.

```ruby
def invalid?(page, field, pattern)
  page.invalid? &&
    ! page.errors[field].empty? &&
    page.errors[field].any? { |msg| msg =~ pattern }
end
```

Now we can use <code>invalid?</code> in all our validations
specifications:

```ruby
context "with missing name" do
  Given(:attrs) { VALID_ATTRS.merge(name: nil) }
  Then { invalid?(page, :name, /blank/) }
end
```

But there is a downside.  Because <code>invalid?</code> only returns
true/false, and there are no mention of the <code>errors</code> object
in the Then clause, the failure message is really uninformative:

    1) Page validations with missing name
       Failure/Error: Then { invalid_on(page, :name, /blank/) }
         Then expression failed at ./spec/models/page_spec.rb:31
           false   <- invalid_on(page, :name, /blank/)
           #<Page name: nil, content: "CONTENT", ...>
                   <- page
       # ./spec/models/page_spec.rb:31:in `block in Then'

All we know is that the page is invalid.  We get no indication of what
fields were actually in error and what the error messages actually
were.

## Custom Failure Message

By abstracting away the details how to check for invalid models (which
is generally a good thing), RSpec/Given lost the ability to give us
the details of why it failed.

Fortunately, there is a simple fix.  Instead of returning a simple
true/false value, the <code>invalid?</code> method should return an
object, that when inspected, tells why it failed.

If a _Then_ clause returns a value that supports a
<code>to_bool</code> method, then RSpec/Given will call that method
before checking for true/false (in rspec-given 3.3.0 or later). All we
need to do is arrange for that object to be returned.

```ruby
  def must_be_invalid(model, field, pattern=//)
    MustBeInvalid.new(model, field, pattern)
  end
```

Since the method no longer returns a true/false value, I've changed
the name from <code>invalid?</code> to <code>must\_be\_invalid</code>.

The code for the <code>MustBeInvalid</code> class is a bit long, but
there is nothing complex in it. The <code>to_bool</code> method
carefully checks for each of our three conditions and records the
exact reason for failure in the @why instance variable. The
<code>inspect</code> method (called by RSpec/Given to display its
value) just returns the @why value with additional details about the
errors on the object.

```ruby
class MustBeInvalid
  def initialize(model, field, pattern)
    @model = model
    @field = field
    @pattern = pattern
    @why = nil
  end

  def to_bool
    if @model.valid?
      @why = "#{@model.class} was valid (expected invalid)"
      false
    elsif @model.errors[@field].empty?
      @why = "#{@model.class} had no errors on field #{@field}" +
             error_descriptions
      false
    elsif @model.errors[@field].none? { |msg| msg =~ @pattern }
      @why = "#{@model.class} had no errors " +
             "matching #{@pattern} on field #{@field}" +
             error_descriptions
      false
    else
      @why = "OK (expected invalid)"
      true
    end
  end

  def inspect
    to_bool if @why.nil?
    @why
  end

  private

  def error_descriptions
    if @model.errors.empty?
      ""
    else
      "\n  Errors were:\n    * " +
        @model.errors.full_messages.
          map { |msg| msg }.join("\n    * ")
    end
  end
end
```

The failure message returned by <code>MustBeInvalid</code> is once
again clear and to the point.  It contains all the information needed
for debugging.

    1) Page validations with missing name
       Failure/Error: Then { must_be_invalid(page, :name, /blank/) }
         Then expression failed at ./spec/models/page_spec.rb:31
           Page had no errors matching (?-mix:blank) on field name
             Errors were:
               * Name is not a wiki name
                        <- must_be_invalid(page, :name, /blank/)
           #<Page name: nil, content: "CONTENT", ...>
                        <- page
       # ./spec/models/page_spec.rb:31:in `block in Then'

## Summary

I've always felt that you can tell the maturity level of a piece of
software by the beauty of the error messages it produces.  By
providing the ability to do custom messages where needed, RSpec/Given
takes a step in that direction.
