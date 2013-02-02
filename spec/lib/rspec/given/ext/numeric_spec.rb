# -*- coding: utf-8 -*-
require 'spec_helper'
require 'rspec/given'
require 'rspec/given/fuzzy_shortcuts'

describe "Numeric Extensions" do
  use_natural_assertions_if_supported

  Given(:n) { 10 }
  Given(:about_n) { about(n) }
  Given(:delta_n) { about(n).delta(0.001) }
  Given(:percent_n) { about(n).percent(5) }
  Given(:epsilon_n) {about(n).epsilon(20) }

  Then { n.±(0.001).exactly_equals?(delta_n) }
  Then { n.‰(5).exactly_equals?(percent_n) }
  Then { n.€(20).exactly_equals?(epsilon_n) }

  Then { n.±.exactly_equals?(about_n) }
  Then { n.‰.exactly_equals?(about_n) }
  Then { n.€.exactly_equals?(about_n) }
end
