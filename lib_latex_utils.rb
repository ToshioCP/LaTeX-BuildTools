require 'fileutils'

# = Module LatexUtils
#
# This module is used by the Rakefile in the directory which this file is located in.

module LatexUtils
  include FileUtils

  class Converters
    def initialize
      @list = {:'.md' => lambda {|src, dst| system ("pandoc -o #{dst} #{src}")} }
    end
    def add suffix, prc
      h = {suffix.to_sym => prc}
      @list.merge!(h)
    end
    def merge! suffix_prc
      @list.merge!(suffix_prc)
    end
    def each
      @list.each{|k,v| yeild(k,v)}
    end
    def exist? suffix
      @list.has_key?(suffix)
    end

    def exec src, dst
      suffix = get_suffix(src).to_sym
      if @list.has_key?(suffix)
        @list[suffix].call(src, dst)
      else
        raise "No such converter."
      end
    end
  end

  def create_converters
    Converters.new
  end
  module_function :create_converters

  class PCS
    def self.get_src_paths src_dir='.'
      # Temporary proc
      parts = get_files([src_dir], /^part(\d+(\.\d+)?)$/, :dir)
      chaps = get_files(parts, /^chap(\d+(\.\d+)?)$/, :dir)
      secs =  get_files(chaps, /^sec(\d+(\.\d+)?)\.[^\/]*$/, :file)
      return [] if secs == [src_dir]
      secs = secs.sort do |sec1, sec2|
        p1, c1, s1 = get_pcs(sec1)
        p2, c2, s2 = get_pcs(sec2)
        if p1 != p2
          p1 <=> p2
        elsif c1 != c2
          c1 <=> c2
        else
          s1 <=> s2
        end
      end
      secs.map{|sec| sec.sub(/^#{src_dir}\//,'')}
    end

    def self.renum_src_files src_dir='.'
      parts = get_files([src_dir], /^part(\d+(\.\d+)?)$/, :dir)
      unless parts == [src_dir]
        renum_files(parts)
        parts = get_files([src_dir], /^part(\d+(\.\d+)?)$/, :dir)
      end
      chaps = parts.map do |part|
        chaps = get_files([part], /^chap(\d+(\.\d+)?)$/, :dir)
        if chaps == [part]
          chaps
        else
          renum_files(chaps)
          get_files([part], /^chap(\d+(\.\d+)?)$/, :dir)
        end
      end.flatten
      secs = chaps.map do |chap|
        secs =  get_files([chap], /^sec(\d+(\.\d+)?)\.[^\/]*$/, :file)
        if secs == [chap]
          secs
        else
          renum_files(secs)
        end
      end.flatten
    end

  private

    def self.get_files dirs, pat, type
      dirs.map do |dir|
        fs = Dir.new(dir).select {|f| f.match?(pat)}
        if type == :dir
          fs.select{|f| Dir.exist?(f)}
        else # type is :file
          fs.select{|f| File.file?(f)}
        end
        if fs == []
          dir
        else
          fs.map{|f| "#{dir}/#{f}"}
        end
      end.flatten.uniq
    end
    def self.get_pcs path
      if path =~ /part(\d+(\.\d+)?)\/chap(\d+(\.\d+)?)\/sec(\d+(\.\d+)?)\.[^\/]*$/
        p = $1; c  = $3; s = $5
      elsif path =~ /chap(\d+(\.\d+)?)\/sec(\d+(\.\d+)?)\.[^\/]*$/
        p = -99999; c = $1; s = $3
      elsif path =~ /sec(\d+(\.\d+)?)\.[^\/]*$/
        p = c = -99999;; s = $1
      else
        p = c = s = -99999
      end
      [p,c,s]
    end
    def self.renum_files(files)
      files = files.sort {|f,g|  f.match(/(\d+(\.\d+)?)(\.[^\/]*)?$/)[1].to_f <=> g.match(/(\d+(\.\d+)?)(\.[^\/]*)?$/)[1].to_f }
      rename_rule = []
      files.each_with_index do |file, i|
        rename_rule << [file, file.gsub(/(\d+(\.\d+)?)(\.[^\/]*)?$/,"_temp#{i+1}\\3"), file.gsub(/(\d+(\.\d+)?)(\.[^\/]*)?$/,"#{i+1}\\3") ]
      end
      rename_rule.each do |rule|
        File.rename rule[0], rule[1]
      end
      rename_rule.each do |rule|
        File.rename rule[1], rule[2]
      end
    end
  end

  def get_src_paths src_dir='.'
    PCS.get_src_paths src_dir
  end
  module_function :get_src_paths

  def renum_src_files src_dir='.'
    PCS.renum_src_files(src_dir)
  end
  module_function :renum_src_files

  # Return: the suffix of the file.
  # It includes the dot.
  # Suffix doesn't havve any dots in the middle of itself usually.
  # But ".src.tex" and ".src.md" are exceptions.
  def get_suffix file
    if file =~ /\.src\.tex$/
      ".src.tex"
    elsif file =~ /\.src\.md$/
      ".src.md"
    else
      File.extname(file)
    end
  end
  module_function :get_suffix

  def is_tex? file
    get_suffix(file) == ".tex"
  end
  module_function :is_tex?

  def get_basename file
    file = File.basename(file)
    file.sub(/#{get_suffix(file)}$/,'')
  end
  module_function :get_basename

  # Return: the relative address of graphic files from the top directory
  def get_graphics_files path
    case get_suffix(path)
    when '.tex', '.src.tex'
      File.read(path).scan(/\\includegraphics(\[.*\])?\{(.*?)\}/).map{|m| m[1]}.uniq
    when '.md'
      File.read(path).scan(/!\[.*?\]\((.*?)\)/).map{|m| m[0]}.uniq
    end
  end
  module_function :get_graphics_files

  # get_input_files doesn't check the extension and existence of the path.
  # Because if is passoble that the path (file) will be created by a converter.
  # It is the user's responsibility that the path will exist when typesetting with lualatex.
  def get_input_files path
    return [] unless is_tex?(path)
    buf = File.read(path)
    verbatim_pattern = /(\\begin\{verbatim\}.*?\\end\{verbatim\}\n)/m
    comment_pattern = /(%.*\n)/
    buf = buf.gsub(verbatim_pattern, '') # remove verbatim
    buf = buf.gsub(comment_pattern,'') # remove cmment
    buf.scan(/\\input\{(.*?)\}/).flatten.uniq
  end
  module_function :get_input_files

  def get_input_files_recursively path, base_dir='.'
    return nil unless path.instance_of?(String) && File.exist?(path)
    files = get_input_files(path)
    files = files + files.map{|f| f="#{base_dir}/#{f}"; get_input_files_recursively(f, base_dir)}.flatten
    files = files.uniq
  end
  module_function :get_input_files_recursively

  def get_input_files_from_files paths
    paths.map{|path| get_input_files(path)}.flatten.uniq
  end
  module_function :get_input_files_from_files

  def mk_main_temp src_dir, build_dir, files, main_temp_tex='main_temp.tex'
    main_tex = <<~EOS
    \\documentclass{ltjsbook}
    \\input{helper.tex}
    \\title{Title}
    \\author{author}
    \\begin{document}
    \\maketitle
    \\tableofcontents

    \\end{document}
    EOS
    mkdir_p("#{src_dir}/#{build_dir}")
    main_tex = File.read("#{src_dir}/main.tex") if File.exist? "#{src_dir}/main.tex"
    body = files.map{|file| "\\input{#{file}}\n"}.join
    main_tex = main_tex.sub(/\\end{document}/, "#{body}\n\\end{document}")
    File.write("#{src_dir}/#{build_dir}/#{main_temp_tex}", main_tex)
  end
  module_function :mk_main_temp

  # example of n_n_n and return value:  '1-1-1' => 'part1/chap1/sec1.src.tex', '1-2' => 'chap1/sec2.md', '1' => 'sec1.tex',
  def num2path n_n_n, src_dir='.'
    return nil unless n_n_n.instance_of? String
    num_pcs = /^(\d+(\.\d+)?)-(\d+(\.\d+)?)-(\d+(\.\d+)?)$/
    num_cs = /^(\d+(\.\d+)?)-(\d+(\.\d+)?)$/
    num_s = /^(\d+(\.\d+)?)$/
    if n_n_n =~ num_pcs
      path = "part#{$1}/chap#{$3}/sec#{$5}"
    elsif n_n_n =~ num_cs
      path = "chap#{$1}/sec#{$3}"
    elsif n_n_n =~ num_s
      path = "sec#{$1}"
    else
      return nil
    end
    srcs = Dir.glob("#{path}.*",base:src_dir)
    return nil if srcs.size != 1
    srcs[0]
  end
  module_function :num2path

end
