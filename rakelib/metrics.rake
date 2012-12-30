METRICS_FILES = FileList['lib/**/*.rb']

task :flog do
  sh "flog #{METRICS_FILES}"
end

task :flay do
  sh "flay #{METRICS_FILES}"
end
