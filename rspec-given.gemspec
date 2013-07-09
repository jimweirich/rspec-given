--- !ruby/object:Gem::Specification
name: rspec-given
version: !ruby/object:Gem::Version
  version: 3.0.0.beta.1
platform: ruby
authors:
- Jim Weirich
autorequire: 
bindir: bin
cert_chain: []
date: 2013-07-09 00:00:00.000000000 Z
dependencies:
- !ruby/object:Gem::Dependency
  name: minitest
  requirement: !ruby/object:Gem::Requirement
    requirements:
    - - ~>
      - !ruby/object:Gem::Version
        version: '5.0'
  type: :runtime
  prerelease: false
  version_requirements: !ruby/object:Gem::Requirement
    requirements:
    - - ~>
      - !ruby/object:Gem::Version
        version: '5.0'
- !ruby/object:Gem::Dependency
  name: sorcerer
  requirement: !ruby/object:Gem::Requirement
    requirements:
    - - '>='
      - !ruby/object:Gem::Version
        version: 0.3.7
  type: :runtime
  prerelease: false
  version_requirements: !ruby/object:Gem::Requirement
    requirements:
    - - '>='
      - !ruby/object:Gem::Version
        version: 0.3.7
description: |
  Given is an RSpec extension that allows the use of Given/When/Then
  terminology when defining specifications.
email: jim.weirich@gmail.com
executables: []
extensions: []
extra_rdoc_files: []
files:
- Gemfile
- Gemfile.lock
- MIT-LICENSE
- README.md
- Rakefile
- TODO
- lib/given.rb
- lib/rspec-given.rb
- lib/given/core.rb
- lib/given/evaluator.rb
- lib/given/ext/numeric.rb
- lib/given/extensions.rb
- lib/given/failure.rb
- lib/given/file_cache.rb
- lib/given/fuzzy_number.rb
- lib/given/fuzzy_shortcuts.rb
- lib/given/line_extractor.rb
- lib/given/module_methods.rb
- lib/given/natural_assertion.rb
- lib/given/version.rb
- lib/minitest/given.rb
- lib/rspec/given.rb
- lib/rspec/given/configure.rb
- lib/rspec/given/have_failed.rb
- lib/rspec/given/have_failed_212.rb
- lib/rspec/given/have_failed_pre212.rb
- lib/rspec/given/monkey.rb
- test/before_test.rb
- test/meme_test.rb
- spec/lib/given/evaluator_spec.rb
- spec/lib/given/ext/numeric_spec.rb
- spec/lib/given/ext/numeric_specifications.rb
- spec/lib/given/extensions_spec.rb
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
- spec/support/faux_then.rb
- spec/support/natural_assertion_control.rb
- examples/example_helper.rb
- examples/failing
- examples/failing/natural_failing_spec.rb
- examples/failing/sample_spec.rb
- examples/integration
- examples/integration/and_spec.rb
- examples/integration/failing
- examples/integration/failing/eval_subexpression_spec.rb
- examples/integration/failing/module_nesting_spec.rb
- examples/integration/failing/undefined_method_spec.rb
- examples/integration/failing_messages_spec.rb
- examples/integration/focused_line_spec.rb
- examples/integration/given_spec.rb
- examples/integration/invariant_spec.rb
- examples/integration/then_spec.rb
- examples/loader.rb
- examples/minitest_helper.rb
- examples/other
- examples/other/line_example.rb
- examples/stack
- examples/stack/stack.rb
- examples/stack/stack_spec.rb
- examples/stack/stack_spec1.rb
- doc/main.rdoc
homepage: http://github.com/jimweirich/rspec-given
licenses:
- MIT
metadata: {}
post_install_message: 
rdoc_options:
- --line-numbers
- --inline-source
- --main
- doc/main.rdoc
- --title
- RSpec Given Extensions
require_paths:
- lib
required_ruby_version: !ruby/object:Gem::Requirement
  requirements:
  - - '>='
    - !ruby/object:Gem::Version
      version: 1.9.2
required_rubygems_version: !ruby/object:Gem::Requirement
  requirements:
  - - '>'
    - !ruby/object:Gem::Version
      version: 1.3.1
requirements: []
rubyforge_project: given
rubygems_version: 2.0.3
signing_key: 
specification_version: 4
summary: Given/When/Then Specification Extensions for RSpec.
test_files: []
