SOURCE_FILES = FileList['lib/**/*.rb']

task :flog do
  sh "flog #{SOURCE_FILES}"
end
