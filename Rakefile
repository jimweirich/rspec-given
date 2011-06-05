#!/usr/bin/ruby -wKU

require 'rake/clean'
require './lib/rspec/given/version'

CLOBBER.include("*.gemspec", "html", "README", "README.old")

# README Formatting --------------------------------------------------

begin
  require 'bluecloth'
rescue LoadError => ex
  puts "WARNING: BlueCloth not available"
end

task :default => :examples

# Running examples ---------------------------------------------------

desc "Run all the examples"
task :examples => [:examples1, :examples2]

desc "Run the examples in RSpec 1"
task :examples1 do
  sh "spec examples/stack/stack_spec1.rb"
end

desc "Run the examples in RSpec 2"
task :examples2 do
  sh "rspec examples"
end

# Formatting the README ----------------------------------------------

directory 'html'

desc "Display the README file"
task :readme => "html/README.html" do
  sh "open html/README.html"
end

desc "format the README file"
task "html/README.html" => ['html', 'README.md'] do
  open("README.md") do |source|
    open('html/README.html', 'w') do |out|
      out.write(BlueCloth.new(source.read).to_html)
    end
  end
end

desc "Generate an RDoc README"
file "README.md" => ["examples/stack/stack_spec.rb", "lib/rspec/given/version.rb"] do
  open("README.md") do |ins|
    open("README.tmp", "w") do |outs|
      state = :copy
      while line = ins.gets
        case state
        when :copy
          if line =~ /version +\d+\.\d+\.\d+/
            line.gsub!(/version +\d+\.\d+\.\d+/, "version #{RSpec::Given::VERSION}")
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
gem "rdoc"
require 'rdoc/task'

begin
  require 'darkfish-rdoc'
  DARKFISH_ENABLED = true
rescue LoadError => ex
  DARKFISH_ENABLED = false
end

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
