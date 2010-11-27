#!/usr/bin/ruby -wKU

require 'rake/clean'

CLOBBER.include("*.gemspec", "html")


# README Formatting --------------------------------------------------

require 'bluecloth'

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
