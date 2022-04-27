require 'rake/clean'
require 'lib_latex_utils.rb'
include Latex_Utils

if File.file?("converter.rb")
  add_conv(eval(File.read("converter.rb")))
end
build_dir = "_build"
raise "main.tex not exist." unless File.exist?('main.tex')
buf = File.read('main.tex')
t = buf.match(/\\title\{(.*?)\}/).to_a[1]
title = t == nil ? "Title" : t
srcs = get_src_paths
pairs = get_src_dst_pairs
dsts = pairs.map{|pair| pair[1]}
subfiles = dsts.map{|dst| "#{build_dir}/#{dst}"}
Dir.mkdir(build_dir) unless Dir.exist?(build_dir)

task default: "#{title}.pdf"

file "#{title}.pdf" => "#{build_dir}/main_temp.pdf" do
  cp "#{build_dir}/main_temp.pdf", "#{title}.pdf"
end

file "#{build_dir}/main_temp.pdf" => "#{build_dir}/main_temp.tex" do
  sh "latexmk -lualatex -pdflualatex=\"lualatex --halt-on-error %O %S\" -output-directory=#{build_dir} #{build_dir}/main_temp.tex"
end

file "#{build_dir}/main_temp.tex" => subfiles do
  mk_main_temp '.', build_dir, subfiles
end

pairs.each do |src, dst|
  file "#{build_dir}/#{dst}" => src do
    conv '.', src, "#{build_dir}/#{dst}"
  end
end

all_graphics_files = []
srcs.each do |src|
  graphics_files = get_graphics_files('.', src)
  file src => graphics_files do
    sh "touch #{src}"
  end
  all_graphics_files += graphics_files
end

all_graphics_files.uniq
all_graphics_files.each do |graphics_file|
  file graphics_file
end

CLEAN << build_dir
CLOBBER << "#{title}.pdf"

task :clean
