#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

require 'lib_latex_utils.rb'
include Latex_Utils

def usage
  print ("Usage:\n")
  print ("part_typeset pattern [src_dir [build_dir]] \n")
end

case ARGV.size
when 1
  src_dir = '.'; build_dir = '_build'
when 2
  src_dir = ARGV[1]; build_dir = '_build'
when 3
  src_dir = ARGV[1]; build_dir = ARGV[2]
else
  usage()
  exit(false)
end

if File.file?("converter.rb")
  add_conv(eval(File.read("converter.rb")))
end
Dir.mkdir(build_dir) unless Dir.exist?(build_dir)
src = num2path ARGV[0]
if src == nil
  print "Pattern couldn't be converted to a source file.\n"
  exit(false)
end
dst = "#{build_dir}/subfile.tex"

conv(src_dir, src, dst)
mk_main_temp(src_dir, build_dir, [dst], 'main_part.tex')
system "latexmk -lualatex -pdflualatex=\"lualatex --halt-on-error %O %S\" -output-directory=#{build_dir} #{build_dir}/main_part.tex"
system 'google-chrome _build/main_part.pdf'
