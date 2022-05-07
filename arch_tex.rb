#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

require 'fileutils'
include FileUtils
require_relative 'lib_latex_utils.rb'
include LatexUtils

# The followig lines will be replaced with a string literal when installed.
rakefile = File.read('Rakefile')
latex_utils = File.read('lib_latex_utils.rb')

readme = <<'EOS'
#### タイプセットの仕方

1. アーカイブファイルを解凍する。
2. 解凍したディレクトリにカレントディレクトリを移す。
3. 端末を起動し、「rake」とタイプする。

#### ファイルについて

- main.texはタイプセットのルートファイルの雛形である。
実際にタイプセットするルートファイルはrakeによって生成される。
main.texにはタイトル、著者の他、表紙などの情報が含まれる。
- helper.texはプリアンブルを記述したふぁいるで、ルートファイルによって取り込まれる。
- sec1.xxx, sec2.xxx ... は本文のファイル。拡張子はtex,src.tex,mdなど。
これらはtexファイルに変換されてからタイプセットされる。
- 画像ファイルなど。
- Rakefile, lib_latex_utils.rbはコンパイルのためのrubyプログラム。

#### タイプセットのためのプログラムについて

これらはGithub上に保管されている。
この文書に同梱されているプログラム意外のユーティリティもGithub上にある。

[Latex Buid Tools](https://github.com/ToshioCP/LaTeX-BuildTools)
EOS

# make directories to write a file like 'dir1/dir2/dir3/file'
def dfwrite path,content
  makedirs(File.dirname(path))
  File.write(path,content)
end

def usage
  print "Usage:\n"
  print "arch_tex [opt] [src_dir]\n"
  print "option:\n"
  print "  -?|-h|--help: Show this message.\n"
  print "  -g: gzip (default), -b: bzip2, -z: zip\n"
end

def get_temp_name
  "temp_"+Time.now.to_f.to_s.gsub(/\./,'')
end

case ARGV.size
when 0
  opt = '-g'; src_dir='.'
when 1
  if ARGV[0] == '-?' || ARGV[0] == '-h' || ARGV[0] == '--help'
    usage(); exit(true)
  elsif ARGV[0] == '-g' || ARGV[0] == '-b' || ARGV[0] == '-z'
    opt = ARGV[0]; src_dir = '.'
  else
    opt = '-g'; src_dir = ARGV[0]
  end
when 2
  if ARGV[0] != '-g' && ARGV[0] != '-b' && ARGV[0] == '-z'
    usage(); exit(false)
  else
    opt = ARGV[0]; src_dir = ARGV[1]
  end
else
  usage(); exit(false)
end
raise "Source directory #{src_dir} not exist." unless Dir.exist?(src_dir)
raise "'main.tex' not exist." unless File.file?("#{src_dir}/main.tex")
main_tex = File.read('main.tex')
title = main_tex.match(/\\title\{(.*?)\}/).to_a[1]
title = title == nil ? "Untitled" : title
temp_dir = get_temp_name()
raise "#{temp_dir} exists. It can't be a temporary directory." if Dir.exist?(temp_dir)
Dir.mkdir(temp_dir)
File.write("#{temp_dir}/Rakefile", rakefile)
File.write("#{temp_dir}/lib_latex_utils.rb", latex_utils)
if File.file?("converter.rb")
  File.write("#{temp_dir}/converter.rb",File.read("converter.rb"))
end
File.write("#{temp_dir}/readme.md", readme)
File.write("#{temp_dir}/main.tex", File.read('main.tex'))
files = get_src_paths(src_dir)+['main.tex']
files = (files + files.map{|f| get_input_files_recursively(f, src_dir)}).flatten.uniq
files.each{|f| dfwrite("#{temp_dir}/#{f}", File.read("#{src_dir}/#{f}"))}
graphics_files = files.map{|f| get_graphics_files("#{src_dir}/#{f}")}.flatten.uniq
graphics_files.each{|f| dfwrite("#{temp_dir}/#{f}", File.read("#{src_dir}/#{f}"))}
Dir.chdir(temp_dir)
files = Dir.glob('**/*')
files = files.select{|f| File.file?(f)}
case opt
when '-b'
  system "tar -cjf ../#{title}.tar.bz2 #{files.join(' ')}"
when '-g'
  system "tar -czf ../#{title}.tar.gz #{files.join(' ')}"
when '-z'
  system "zip ../#{title}.zip #{files.join(' ')}"
else
  print "Unexpected error (Illegal option).\n"
end

Dir.chdir('..')
remove_entry_secure(temp_dir)
