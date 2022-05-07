require 'rake/clean'
require_relative 'lib_latex_utils.rb'

include LatexUtils

@converters = Converters.new
if File.file?("converter.rb")
  @converters.merge!(eval(File.read("converter.rb")))
end
raise "main.tex not exist." unless File.exist?('main.tex')
buf = File.read('main.tex')
t = buf.match(/\\title\{(.*?)\}/).to_a[1]
case t
when nil, "" then title = "Title"
else title = t
end

build_dir = @build_dir = "_build" # default build directory. You can customize it.
Dir.mkdir(build_dir) unless Dir.exist?(build_dir)

def dst src
  if is_tex?(src)
    src
  else
    "#{@build_dir}/#{File.dirname(src).gsub(/\//,'_')}_#{get_basename(src)}.tex"
  end
end

srcs = get_src_paths(".")
dsts = srcs.map{|src| dst(src)}
# Record the relations between srcs and dsts.
pairs = srcs.map{|src| "#{src} => #{dst(src)}\n"}.join
File.write("#{build_dir}/pairs.txt", pairs)

task default: "#{title}.pdf"

file "#{title}.pdf" => "#{build_dir}/main_temp.pdf" do
  cp "#{build_dir}/main_temp.pdf", "#{title}.pdf"
end

file "#{build_dir}/main_temp.pdf" => "#{build_dir}/main_temp.tex" do
  sh "latexmk -lualatex -pdflualatex=\"lualatex --halt-on-error %O %S\" -output-directory=#{build_dir} #{build_dir}/main_temp.tex"
end

file "#{build_dir}/main_temp.tex" => dsts do
  mk_main_temp '.', build_dir, dsts, "main_temp.tex"
end

srcs.each do |src|
  unless is_tex?(src)
    file dst(src) => src do
      @converters.exec src, dst(src)
    end
  end
end

srcs.each do |src|
  graphics_files = get_graphics_files(src)
  unless graphics_files == []
    file src => graphics_files do
      sh "touch #{src}"
    end
  end
  input_files = get_input_files_recursively(src, '.')
  unless input_files == []
    file src => input_files do
      sh "touch #{src}"
    end
  end
end

all_graphics_files = srcs.map{|src| get_graphics_files(src)}.flatten.uniq
all_graphics_files.each do |graphics_file|
  file graphics_file
end
all_input_files = srcs.map{|src| get_input_files_recursively(src, '.')}.flatten.uniq
all_input_files.each do |input_file|
  file input_file
end

CLEAN << build_dir
CLOBBER << "#{title}.pdf"

task :clean
