require './rakelib/bundler_fix'

METRICS_FILES = FileList['lib/**/*.rb']

task :check_flog do
  sh "type flog >/dev/null 2>&1", :verbose => false do |status|
    fail "Install flog to generate complexity metrics" unless status
  end
end

task :check_flay do
  sh "type flay >/dev/null 2>&1", :verbose => false do |status|
    fail "Install flay to generate complexity metrics" unless status
  end
end

desc "Run complexity metrics"
task :flog, [:all] => :check_flog do |t, args|
  flags = args.all ? "--all" : ""
  nobundle do
    sh "flog #{flags} #{METRICS_FILES}"
  end
end

desc "Run duplication metrics"
task :flay => :check_flay do
  nobundle do
    sh "flay #{METRICS_FILES}"
  end
end
