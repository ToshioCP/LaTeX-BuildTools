# suffix_proc

{ :'src.tex' => lambda do |src, dst|
    buf = File.read(src)
    buf = buf.split(/(\\begin\{verbatim\}.*?\\end\{verbatim\}\n)/m)
    buf = buf.map do |s|
      s.match?(/^\\begin\{verbatim\}/) ? s : s.split(/(%.*$)/)
    end
    buf = buf.flatten
    buf.each do |s|
      unless s.match?(/^\\begin\{verbatim\}/) || s.match?(/^%/)
        # Put some codes to translate the string pointed by s
        # s.gsub!(/latex/) {"\\LaTeX"}
      end
    end
    File.write(dst, buf.join)
  end }
