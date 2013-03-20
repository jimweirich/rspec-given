require 'rspec/given'

# Load the support modules.

dir = File.dirname(__FILE__)
Dir[dir + "/support/*.rb"].each do |fn|
  load fn
end
