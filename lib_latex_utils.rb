module Latex_Utils

  # src: relative path from src_dir
  # dst: no relation to src_dir
  @@conv = {md: lambda {|src, dst| system ("pandoc -o #{dst} #{src}")} }

  # convert relative paths into absolute paths if the paths appear in input or includegraphics command.
  def paths_r2a src_dir, src, dst
    buf = File.read("#{src_dir}/#{src}")
    buf = buf.split(/(\\begin\{verbatim\}.*?\\end\{verbatim\}\n)/m)
    buf = buf.map do |s|
      s.match?(/^\\begin\{verbatim\}/) ? s : s.split(/(%.*$)/)
    end
    buf = buf.flatten
    buf.each_with_index do |s, i|
      unless s.match?(/^\\begin\{verbatim\}/) || s.match?(/^%/)
        pairs = s.scan(/\\input\{.*?\}/).uniq.map{|t| f=t.match(/\{(.*?)\}/)[1]; [f, File.realpath("#{src_dir}/#{f}")]}
        pairs.each{|pair| s = s.gsub(/\\input\{#{pair[0]}\}/,"\\input{#{pair[1]}}")}
        pairs = s.scan(/\\includegraphics\[.*?\]\{.*?\}/).uniq.map{|t| f=t.match(/\{(.*?)\}/)[1]; [f, File.realpath("#{src_dir}/#{f}")]}
        pairs.each{|pair| s = s.gsub(/\\includegraphics\[(.*?)\]\{#{pair[0]}\}/,"\\includegraphics[\\1]{#{pair[1]}}")}
        pairs = s.scan(/\\includegraphics\{.*?\}/).uniq.map{|t| f=t.match(/\{(.*?)\}/)[1]; [f, File.realpath("#{src_dir}/#{f}")]}
        pairs.each{|pair| s = s.gsub(/\\includegraphics\{#{pair[0]}\}/,"\\includegraphics{#{pair[1]}}")}
      end
      buf[i] = s
    end
    File.write(dst, buf.join)
  end

  def get_suffix file
    file.match(/\.([^\/]*)$/).to_a[1]
  end

  def add_conv suffix_proc
    @@conv = @@conv.merge(suffix_proc)
  end

  def conv src_dir, src, dst
    if get_suffix(src) == "tex"
      paths_r2a(src_dir, src, dst)
    else
      temp = get_temp_name()+".tex"
      raise "Converter for #{get_suffix(src)} not exist." if @@conv[get_suffix(src).to_sym] == nil
      @@conv[get_suffix(src).to_sym].call("#{src_dir}/#{src}", "#{src_dir}/#{temp}")
      paths_r2a(src_dir, temp, dst)
      File.delete("#{src_dir}/#{temp}")
    end
  end

  def get_graphics_files_from_tex src_dir, file
    File.read("#{src_dir}/#{file}").scan(/\\includegraphics(\[.*\])?\{(.*?)\}/).map{|m| m[1]}.uniq
  end

  def get_graphics_files_from_md src_dir, file
    File.read("#{src_dir}/#{file}").scan(/!\[.*?\]\((.*?)\)/).map{|m| m[0]}.uniq
  end

  def get_graphics_files src_dir, file
    case get_suffix(file)
    when 'tex' then get_graphics_files_from_tex(src_dir, file)
    when 'src.tex' then get_graphics_files_from_tex(src_dir, file)
    when 'md'  then get_graphics_files_from_md(src_dir, file)
    end
  end

  def get_input_files src_dir, file
    File.read("#{src_dir}/#{file}").scan(/\\input\{(.*?)\}/).flatten.uniq
  end

  def get_input_files_recursively src_dir, file
    return nil unless file.instance_of?(String) && File.exist?("#{src_dir}/#{file}")
    files = get_input_files(src_dir, file)
    texfiles = files.select{|f| f =~ /.tex$/}
    files = files + texfiles.map{|tf| get_input_files_recursively(src_dir, tf)}.flatten
    files = files.uniq
  end

  def get_input_files_from_files src_dir, files
    files.map{|file| get_input_files(src_dir, file)}.flatten.uniq
  end

  @@patterns = [ /^part(\d+(\.\d+)?)$/, /^chap(\d+(\.\d+)?)$/, /^sec(\d+(\.\d+)?)\./ ]

  def renum_src_files src_dir='.'
    renum_src_files_0 src_dir, @@patterns
  end

  #Example: get_src_paths() => ["part1/chap1/sec1.tex","part1/chap1/sec2.src.tex","part1/chap2/sec1.md"]
  def get_src_paths src_dir='.'
    paths = get_src_paths_0 src_dir, @@patterns
    paths = paths.map{|path| path.sub(/#{src_dir}\//,'')}
    pcs_pat = ['part', 'chap', 'sec'].map{|pcs| Regexp.compile("#{pcs}(\\d+(\\.\\d+)?)")}
    paths = paths.sort do |p1, p2|
      result = nil
      (0 ..2).each do |i|
        if p1.match?(pcs_pat[i]) && p2.match?(pcs_pat[i]) && p1.match(pcs_pat[i])[1].to_f != p2.match(pcs_pat[i])[1].to_f
          result = p1.match(pcs_pat[i])[1].to_f <=> p2.match(pcs_pat[i])[1].to_f
          break
        end
      end
      result
    end
    paths
  end

  #Example: get_src_dst_pairs() => [["part1/chap1/sec1.tex","subfile1.tex"], ["part1/chap1/sec2.src.tex","subfile2.tex], ["part1/chap2/sec1.md","subfile3.tex"]]
  def get_src_dst_pairs src_dir='.'
    paths = get_src_paths src_dir
    (1 .. paths.size).map {|i| [paths[i-1], "subfile#{i}.tex"]}
  end

  @main_tex = <<~EOS
  \\documentclass{ltjsbook}
  \\input{helper.tex}
  \\title{Title}
  \\author{author}
  \\begin{document}
  \\maketitle
  \\tableofcontents

  \\end{document}
  EOS

  def mk_main_temp src_dir, build_dir, files, temp_file='main_temp.tex'
    if File.exist? "#{src_dir}/main.tex"
      main_tex = File.read("#{src_dir}/main.tex")
    else
      main_tex = @main_tex
    end
    temp = "#{get_temp_name()}.tex"
    dst = "#{build_dir}/#{temp_file}"
    File.write("#{src_dir}/#{temp}", main_tex)
    conv(src_dir, temp, dst)
    File.delete("#{src_dir}/#{temp}")
    main_tex = File.read(dst)
    body = files.map{|file| "\\input{#{file}}\n"}.join
    main_tex = main_tex.sub(/\\end{document}/, "#{body}\n\\end{document}")
    File.write(dst, main_tex)
  end

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

  # example of path and return value:  'part1/chap1/sec1.src.tex' => '1-1-1', 'chap1/sec2.md' => '1-2', 'sec1.tex' => '1',
  def path2num path
    return nil unless path.instance_of? String
    path_pcs = /^part(\d+(\.\d+)?)\/chap(\d+(\.\d+)?)\/sec(\d+(\.\d+)?)\.(.+)$/
    path_cs = /^chap(\d+(\.\d+)?)\/sec(\d+(\.\d+)?)\.(.+)$/
    path_s = /^sec(\d+(\.\d+)?)\.(.+)$/
    if path =~ path_pcs
      "#{$1}-#{$3}-#{$5}"
    elsif path =~ path_cs
      "#{$1}-#{$3}"
    elsif path =~ path_s
      "#{$1}"
    else
       nil
    end
  end

private

  def get_temp_name
    "temp_"+Time.now.to_f.to_s.gsub(/\./,'')
  end

  def renum_src_files_0 src_dir, patterns
    size = patterns.size
    return if size == 0
    patterns_next = patterns.dup
    patterns_next.delete_at(0)
    files = Dir.children(src_dir).select {|f| f.match?(patterns[0])}
    if files == [] && size >=1
      renum_src_files_0 src_dir, patterns_next
    else
      files.each do |file|
        renum_src_files_0 "#{src_dir}/#{file}", patterns_next if File.directory?("#{src_dir}/#{file}") && size >= 2
      end
      #renumber the 'dir'
      files = files.sort {|f,g|  f.match(/\d+(\.\d+)?/)[0].to_f <=> g.match(/\d+(\.\d+)?/)[0].to_f }
      rename_rule = []
      files.each_with_index do |file, i|
        rename_rule << ["#{src_dir}/"+file, "#{src_dir}/"+file.gsub(/\d+(\.\d+)?/,"_temp#{i+1}"), "#{src_dir}/"+file.gsub(/\d+(\.\d+)?/, "#{i+1}") ]
      end
      rename_rule.each do |rule|
        File.rename rule[0], rule[1]
      end
      rename_rule.each do |rule|
        File.rename rule[1], rule[2]
      end
    end
  end

  def get_src_paths_0 src_dir, patterns
    size = patterns.size
    return [] if size == 0
    patterns_next = patterns.dup
    patterns_next.delete_at(0)
    files = Dir.new(src_dir).select {|f| f.match?(patterns[0])}
    if files == [] && patterns_next.size >= 1
      get_src_paths_0(src_dir, patterns_next)
    else
      paths = []
      files.each do |file|
        if File.directory?("#{src_dir}/#{file}") && patterns_next.size >= 1
          paths_0 = get_src_paths_0 "#{src_dir}/#{file}", patterns_next
          paths += paths_0 if paths_0 != nil
        elsif File.stat("#{src_dir}/#{file}").file? && size == 1
          paths << "#{src_dir}/#{file}"
        end
      end
      paths
    end
  end

end
