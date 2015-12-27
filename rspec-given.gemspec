--- !ruby/object:Gem::Specification
name: rspec-given
version: !ruby/object:Gem::Version
  version: 3.7.1
platform: ruby
authors:
- Jim Weirich
autorequire: 
bindir: bin
cert_chain: []
date: 2015-12-23 00:00:00.000000000 Z
dependencies:
- !ruby/object:Gem::Dependency
  name: given_core
  requirement: !ruby/object:Gem::Requirement
    requirements:
    - - '='
      - !ruby/object:Gem::Version
        version: 3.7.1
  type: :runtime
  prerelease: false
  version_requirements: !ruby/object:Gem::Requirement
    requirements:
    - - '='
      - !ruby/object:Gem::Version
        version: 3.7.1
- !ruby/object:Gem::Dependency
  name: rspec
  requirement: !ruby/object:Gem::Requirement
    requirements:
    - - ">="
      - !ruby/object:Gem::Version
        version: 2.14.0
  type: :runtime
  prerelease: false
  version_requirements: !ruby/object:Gem::Requirement
    requirements:
    - - ">="
      - !ruby/object:Gem::Version
        version: 2.14.0
description: |
  Given is an RSpec extension that allows the use of Given/When/Then
  terminology when defining specifications.
email: jim.weirich@gmail.com
executables: []
extensions: []
extra_rdoc_files: []
files:
- Gemfile
- MIT-LICENSE
- README.md
- Rakefile
- TODO
- doc
- doc/article
- doc/article/custom_error_messages.md
- doc/main.rdoc
- examples
- examples/active_support_helper.rb
- examples/example_helper.rb
- examples/failing
- examples/failing/natural_failing_spec.rb
- examples/failing/sample_spec.rb
- examples/integration
- examples/integration/and_spec.rb
- examples/integration/failing
- examples/integration/failing/eval_subexpression_spec.rb
- examples/integration/failing/module_nesting_spec.rb
- examples/integration/failing/oddly_formatted_then.rb
- examples/integration/failing/to_bool_returns_false.rb
- examples/integration/failing/undefined_method_spec.rb
- examples/integration/failing_messages_spec.rb
- examples/integration/focused_line_spec.rb
- examples/integration/given_spec.rb
- examples/integration/invariant_spec.rb
- examples/integration/then_spec.rb
- examples/loader.rb
- examples/minitest
- examples/minitest-rails
- examples/minitest-rails/test_case_spec.rb
- examples/minitest/assert_raises_spec.rb
- examples/minitest_helper.rb
- examples/other
- examples/other/line_example.rb
- examples/stack
- examples/stack/stack.rb
- examples/stack/stack_spec.rb
- examples/stack/stack_spec1.rb
- examples/use_assertions.rb
- lib
- lib/given.rb
- lib/rspec-given.rb
- lib/rspec/given.rb
- rakelib
- rakelib/bundler_fix.rb
- rakelib/gemspec.rake
- rakelib/metrics.rake
- rakelib/preview.rake
- spec
- spec/lib/given/assertions_spec.rb
- spec/lib/given/binary_operation_spec.rb
- spec/lib/given/evaluator_spec.rb
- spec/lib/given/ext/numeric_spec.rb
- spec/lib/given/ext/numeric_specifications.rb
- spec/lib/given/extensions_spec.rb
- spec/lib/given/failing_thens_spec.rb
- spec/lib/given/failure_matcher_spec.rb
- spec/lib/given/failure_spec.rb
- spec/lib/given/file_cache_spec.rb
- spec/lib/given/fuzzy_number_spec.rb
- spec/lib/given/have_failed_spec.rb
- spec/lib/given/lexical_purity_spec.rb
- spec/lib/given/line_extractor_spec.rb
- spec/lib/given/module_methods_spec.rb
- spec/lib/given/natural_assertion_spec.rb
- spec/lib/given/options_spec.rb
- spec/spec_helper.rb
- spec/support/be_booleany.rb
- spec/support/failure_and_errors.rb
- spec/support/faux_then.rb
- spec/support/natural_assertion_control.rb
- support
homepage: http://github.com/rspec-given/rspec-given
licenses:
- MIT
metadata: {}
post_install_message: 
rdoc_options:
- "--line-numbers"
- "--inline-source"
- "--main"
- doc/main.rdoc
- "--title"
- RSpec Given Extensions
require_paths:
- lib
required_ruby_version: !ruby/object:Gem::Requirement
  requirements:
  - - ">="
    - !ruby/object:Gem::Version
      version: 1.9.2
required_rubygems_version: !ruby/object:Gem::Requirement
  requirements:
  - - ">="
    - !ruby/object:Gem::Version
      version: '0'
requirements: []
rubyforge_project: given
rubygems_version: 2.4.5.1
signing_key: 
specification_version: 4
summary: Given/When/Then Specification Extensions for RSpec.
test_files: []
