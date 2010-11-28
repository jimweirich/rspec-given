#!/usr/bin/ruby -wKU

require 'rake/clean'

CLOBBER.include("*.gemspec", "html")


# README Formatting --------------------------------------------------

require 'bluecloth'


task :default => :examples

# Running examples ---------------------------------------------------

desc "Run the examples"
task :examples do
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

# RDoc ---------------------------------------------------------------
require 'rake/rdoctask'

begin
  require 'darkfish-rdoc'
  DARKFISH_ENABLED = true
rescue LoadError => ex
  DARKFISH_ENABLED = false
end

BASE_RDOC_OPTIONS = [
  '--line-numbers', '--inline-source',
  '--main' , 'README.rdoc',
  '--title', 'RSpec::Given - Given/When/Then Extensions for RSpec'
]

rd = Rake::RDocTask.new("rdoc") do |rdoc|
  rdoc.rdoc_dir = 'html'
#  rdoc.template = 'doc/jamis.rb'
  rdoc.title    = "Rake -- Ruby Make"
  rdoc.options = BASE_RDOC_OPTIONS.dup
  rdoc.options << '-SHN' << '-f' << 'darkfish' if DARKFISH_ENABLED

  rdoc.rdoc_files.include('README.md', 'MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
end
