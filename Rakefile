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
