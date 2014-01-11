require 'rspec/given'

describe "arrays split over multiple lines" do
  When(:result) { 'anything' }
  Then { result == ['a',
                    'a'] }
end
