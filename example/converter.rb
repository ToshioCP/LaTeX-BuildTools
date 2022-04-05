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
        s = s.gsub(/perm3\((\d),(\d),(\d)\)/) {"\\begin{bmatrix}#{$1}& &1\\\\#{$2}&\\leftarrow&2\\\\#{$3}& &3\\end{bmatrix}"}
        s = s.gsub(/perm4\((\d),(\d),(\d),(\d)\)/) {"\\begin{bmatrix}#{$1}& &1\\\\#{$2}&\\leftarrow&2\\\\#{$3}& &3\\\\#{$4}& &4\\end{bmatrix}"}
      end
    end
    File.write(dst, buf.join)
  end }
