#!/usr/bin/ruby -wKU

require 'rake/clean'
require './lib/rspec/given/version'

CLEAN.include("pkg/rspec-given-*").exclude("pkg/*.gem")
CLOBBER.include("*.gemspec", "html", "README", "README.old")

# README Formatting --------------------------------------------------

begin
  require 'bluecloth'
rescue LoadError => ex
  puts "WARNING: BlueCloth not available"
end

task :default => :ex2

def version
  RSpec::Given::VERSION
end

def tag_name
  "rspec-given-#{version}"
end

def tagged?
  `git tag`.split.include?(tag_name)
end

def git_clean?
  sh "git status | grep 'nothing to commit'", :verbose => false do |status|
    return status
  end
end

desc "Display the current version tag"
task :version do
  puts tag_name
end

desc "Tag the current commit with #{tag_name}"
task :tag do
  fail "Cannot tag, project directory is not clean" unless git_clean?
  fail "Cannot tag, #{tag_name} already exists." if tagged?
  sh "git tag #{tag_name}"
end

# Running examples ---------------------------------------------------

desc "Run all the examples"
task :examples => [:specs, :examples1, :examples2]

desc "Run the RSpec 2 specs and examples"
task :ex2 => [:specs, :examples2]

desc "Run the specs"
task :specs do
  puts "Running specs"
  sh "rspec spec"
end

desc "Run the examples in RSpec 1"
task :examples1 => [:verify_rspec1] do
  puts "Running examples (with RSpec2)"
  sh "spec examples/stack/stack_spec1.rb"
end

EXAMPLES = FileList['examples/**/*_spec.rb'].
  exclude('examples/failing/*.rb').
  exclude('examples/integration/failing/*.rb')
FAILING_EXAMPLES = FileList['examples/failing/**/*_spec.rb']

desc "Run the examples in RSpec 2"
task :examples2 => [:verify_rspec2] do
  puts "Running examples (with RSpec2)"
  sh "rspec #{EXAMPLES}"
end

desc "Run failing examples"
task :failing => [:verify_rspec2] do
  puts "Running failing examples (with RSpec2)"
  sh "rspec #{FAILING_EXAMPLES}"
end

task :verify_rspec1 do
  sh "type spec >/dev/null 2>&1", :verbose => false do |status|
    fail "You need to install RSpec 1 in order to test against it." unless status
  end
end

task :verify_rspec2 do
  sh "type rspec >/dev/null 2>&1", :verbose => false do |status|
    fail "You need to install RSpec 2 in order to test against it." unless status
  end
end

task :load_check do
  SRC_FILES = FileList['lib/rspec/given/*.rb'].exclude(/rspec1/)
  SRC_FILES.each do |fn|
    sh %{ruby -Ilib -e 'load "#{fn}"'}
  end
end

# Formatting the README ----------------------------------------------

directory 'html'

desc "Display the README file"
task :readme => ["README.md"] do
  sh "ghpreview README.md"
end

desc "Generate an RDoc README"
file "README.md" => ["examples/stack/stack_spec.rb", "lib/rspec/given/version.rb"] do
  open("README.md") do |ins|
    open("README.tmp", "w") do |outs|
      state = :copy
      while line = ins.gets
        case state
        when :copy
          if line =~ /rspec-given, version +\d+(\.(\d+|beta))+/i
            line.gsub!(/version +\d+(\.(\d+|beta))+/i, "version #{RSpec::Given::VERSION}")
            outs.puts line
          elsif line =~ /^<pre>/
            state = :insert
          else
            outs.puts line
          end
        when :insert
          outs.puts "<pre>"
          outs.puts open("examples/stack/stack_spec.rb") { |codes| codes.read }
          outs.puts "</pre>"
          state = :skip
        when :skip
          state = :copy2 if line =~ /^<\/pre>/
        when :copy2
          outs.puts line
        end
      end
    end
  end
  mv "README.md", "README.old"
  mv "README.tmp", "README.md"
end


# RDoc ---------------------------------------------------------------
begin
  gem "rdoc"
  require 'rdoc/task'
  RDOC_ENABLED = true
rescue LoadError => ex
  RDOC_ENABLED = false
end

begin
  require 'darkfish-rdoc'
  DARKFISH_ENABLED = true
rescue LoadError => ex
  DARKFISH_ENABLED = false
end

if RDOC_ENABLED
  def md_to_rdoc(infile, outfile)
    open(infile) do |ins|
      open(outfile, "w") do |outs|
        state = :copy
        while line = ins.gets
          case state
          when :ignore
            if line =~ /^-->/
              state = :copy
            end
          when :pre
            if line =~ /^<\/pre>/
              state = :copy
            else
              outs.puts "    #{line}"
            end
          when :copy
            if line =~ /^<!--/
              state = :ignore
            elsif line =~ /^<pre>/
              state = :pre
            else
              line.gsub!(/^####/, '====')
              line.gsub!(/^###/, '===')
              line.gsub!(/^##/, '==')
              line.gsub!(/^#/, '=')
              outs.puts line
            end
          end
        end
      end
    end
  end

  file "README" => ["README.md"] do
    md_to_rdoc("README.md", "README")
  end

  RDoc::Task.new("rdoc") do |rdoc|
    rdoc.rdoc_dir = 'html'
    rdoc.title    = "RSpec/Given -- A Given/When/Then extension for RSpec"
    rdoc.options = [
      '--line-numbers',
      '--main' , 'README',
      '--title', 'RSpec::Given - Given/When/Then Extensions for RSpec'
    ]
    rdoc.options << '-SHN' << '-f' << 'darkfish' if DARKFISH_ENABLED

    rdoc.rdoc_files.include('README')
    rdoc.rdoc_files.include('MIT-LICENSE')
    rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
  end

  task :rdoc => "README"
end
