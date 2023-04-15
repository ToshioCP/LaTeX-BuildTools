require "rdoc/task"
require "rake/testtask"

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.title = "LaTeX-Buildtools"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README.md", "License.md", "Tutorial.en.md", "Tutorial.ja.md", "lib/lbt.rb", "lib/lbt/*.rb")
end
task :rdoc do
  touch "doc/.nojekyll"
end

Rake::TestTask.new do |t|
  # t.libs << "test"
  t.test_files = Dir.glob("test/test_*")
  t.verbose = true
end
