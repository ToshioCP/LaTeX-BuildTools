# suffix_proc

{ :'.src.tex' => lambda do |src, dst|
    # Each pattern has a pair of round bracket that surrouds the pattern.
    # So, the result of the method split containes the matched string.
    verbatim_pattern = /(\\begin\{verbatim\}.*?\\end\{verbatim\}\n)/m
    comment_pattern = /(%.*\n)/
    buf = File.read(src)
    buf = buf.split(verbatim_pattern)\
             .map{|s| s.match?(verbatim_pattern) ? s : s.split(/comment_pattern/)}\
             .flatten
    buf = buf.map do |s|
      unless s.match?(verbatim_pattern) || s.match?(comment_pattern)
        s
        # Put some codes to translate the string pointed by s
        # For example, s.gsub(/latex/) {"\\LaTeX"}
      else
        s
      end
    end
    File.write(dst, buf.join)
  end }
