$LOAD_PATH << './examples/stack'

if defined?(RSpec)
  require 'rspec/given'
  require 'spec_helper'

  RSpec.configure do |config|
    # Before RSpec 3.4, RSpec would only print lines in failures from spec files.
    # Starting in 3.4, it now prints lines from the new `project_source_dirs` config
    # setting. We want it to look for lines from our examples, and since its not the
    # standard `spec` dir, we have to tell RSpec about it here.
    # See #18 for more discussion.
    config.project_source_dirs << "examples" if config.respond_to?(:project_source_dirs)
  end
else
  require 'minitest/autorun'
  require 'active_support_helper'
  require 'minitest/given'
  require 'minitest_helper'
end
