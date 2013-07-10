require 'rubygems/package_task'
require './lib/given/version'

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  PKG_FILES = FileList[
    '[A-Z]*',
    'lib/*.rb',
    'lib/**/*.rb',
    'rakelib/**/*',
    'test/**/*.rb',
    'spec/**/*.rb',
    'examples/**/*',
    'doc/**/*',
  ]
  PKG_FILES.exclude('TAGS')
  GIVEN_CORE_FILES = FileList[*PKG_FILES].
    exclude("lib/*-given.rb").
    exclude("lib/rspec/**/*").
    exclude("lib/minitest/**/*").
    exclude("spec/**/*").
    exclude("examples/**/*")
  RSPEC_GIVEN_FILES = FileList[*PKG_FILES].
    exclude("lib/mini*/**/*").
    exclude("lib/minitest-given.rb").
    exclude("lib/given/**/*")
  MINITEST_GIVEN_FILES = FileList[*PKG_FILES].
    exclude("spec/**/*").
    exclude("lib/rspec-given.rb").
    exclude("lib/rspec*/**/*").
    exclude("lib/given/**/*")

  RSPEC_GIVEN_SPEC = Gem::Specification.new do |s|
    s.name = 'rspec-given'
    s.version = Given::VERSION
    s.summary = "Given/When/Then Specification Extensions for RSpec."
    s.description = <<EOF
Given is an RSpec extension that allows the use of Given/When/Then
terminology when defining specifications.
EOF
    s.files = RSPEC_GIVEN_FILES.to_a
    s.require_path = 'lib'                         # Use these for libraries.
    s.rdoc_options = [
      '--line-numbers', '--inline-source',
      '--main' , 'doc/main.rdoc',
      '--title', 'RSpec Given Extensions'
    ]

    s.add_dependency("given_core", "= #{Given::VERSION}")
    s.add_dependency("rspec", ">= 2.12")

    s.required_ruby_version = '>= 1.9.2'
    s.license = "MIT"

    s.author = "Jim Weirich"
    s.email = "jim.weirich@gmail.com"
    s.homepage = "http://github.com/jimweirich/rspec-given"
    s.rubyforge_project = "given"
  end

  MINITEST_GIVEN_SPEC = Gem::Specification.new do |s|
    s.name = 'minitest-given'
    s.version = Given::VERSION
    s.summary = "Given/When/Then Specification Extensions for Minitest::Spec."
    s.description = <<EOF
Given is a Minitest::Spec extension that allows the use of Given/When/Then
terminology when defining specifications.
EOF
    s.files = MINITEST_GIVEN_FILES.to_a
    s.require_path = 'lib'                         # Use these for libraries.
    s.rdoc_options = [
      '--line-numbers', '--inline-source',
      '--main' , 'doc/main.rdoc',
      '--title', 'Minitest::Spec Given Extensions'
    ]

    s.add_dependency("given_core", "= #{Given::VERSION}")
    s.add_dependency("minitest", "> 4.3")

    s.required_ruby_version = '>= 1.9.2'
    s.license = "MIT"

    s.author = "Jim Weirich"
    s.email = "jim.weirich@gmail.com"
    s.homepage = "http://github.com/jimweirich/rspec-given"
    s.rubyforge_project = "given"
  end

  GIVEN_CORE_SPEC = Gem::Specification.new do |s|
    s.name = 'given_core'
    s.version = Given::VERSION
    s.summary = "Core engine for RSpec::Given and Minitest::Given."
    s.description = <<EOF
Given_core is the basic functionality behind rspec-given and minitest-given,
extensions that allow the use of Given/When/Then terminology when defining
specifications.
EOF
    s.files = GIVEN_CORE_FILES.to_a
    s.require_path = 'lib'                         # Use these for libraries.
    s.rdoc_options = [
      '--line-numbers', '--inline-source',
      '--main' , 'doc/main.rdoc',
      '--title', 'RSpec Given Extensions'
    ]

    s.add_dependency("sorcerer", ">= 0.3.7")

    s.required_ruby_version = '>= 1.9.2'
    s.license = "MIT"

    s.author = "Jim Weirich"
    s.email = "jim.weirich@gmail.com"
    s.homepage = "http://github.com/jimweirich/rspec-given"
    s.rubyforge_project = "given"
  end

  Gem::PackageTask.new(MINITEST_GIVEN_SPEC) do |pkg|
    pkg.need_zip = false
    pkg.need_tar = false
  end

  Gem::PackageTask.new(RSPEC_GIVEN_SPEC) do |pkg|
    pkg.need_zip = false
    pkg.need_tar = false
  end

  Gem::PackageTask.new(GIVEN_CORE_SPEC) do |pkg|
    pkg.need_zip = false
    pkg.need_tar = false
  end

  file "rspec-given.gemspec" => ["rakelib/gemspec.rake"] do |t|
    require 'yaml'
    open(t.name, "w") { |f| f.puts RSPEC_GIVEN_SPEC.to_yaml }
  end

  file "minitest-given.gemspec" => ["rakelib/gemspec.rake"] do |t|
    require 'yaml'
    open(t.name, "w") { |f| f.puts MINITEST_GIVEN_SPEC.to_yaml }
  end

  file "given_core.gemspec" => ["rakelib/gemspec.rake"] do |t|
    require 'yaml'
    open(t.name, "w") { |f| f.puts GIVEN_CORE_SPEC.to_yaml }
  end

  desc "Create a stand-alone gemspec"
  task :gemspec => ["rspec-given.gemspec", "minitest-given.gemspec", "given_core.gemspec"]

  desc "Check Filelists"
  task :filelists do
    puts "==============="
    puts "GIVEN_CORE_FILES=#{GIVEN_CORE_FILES.inspect}"
    puts "==============="
    puts "RSPEC_GIVEN_FILES=#{RSPEC_GIVEN_FILES.inspect}"
    puts "==============="
    puts "MINITEST_GIVEN_FILES=#{MINITEST_GIVEN_FILES.inspect}"
    puts "==============="
  end
end
