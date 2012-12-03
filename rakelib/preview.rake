
task :preview do
  sh "ghpreview #{FileList['README.*']}"
end
