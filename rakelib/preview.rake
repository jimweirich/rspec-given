require './rakelib/bundler_fix'

task :check_preview do
  sh "type ghpreview >/dev/null 2>&1", :verbose => false do |status|
    fail "Install ghpreview to generate a local REAMDE preview page" unless status
  end
end

desc "Generate the GitHub readme locally"
task :preview => :check_preview do
  nobundle do
    sh "ghpreview #{FileList['README.*']}"
  end
end
