require_relative 'utils.rb'

module Lbt
  def part_typeset file_or_number, preview = false
    return unless file_or_number.is_a? String
    if File.file?(file_or_number)
      file = file_or_number
    else
      file = num2path(file_or_number)
      return unless File.file? file
    end

    m = File.read(".config").match(/^build_dir = (.*)$/)
    build_dir = m[1] ? m[1] : "_build"
    raise "main.tex not exist." unless File.exist?('main.tex')
    mkdir build_dir unless Dir.exist?(build_dir)

    main_tex = File.read('main.tex')
    main_tex = main_tex.sub(/\\end{document}/, "\\input{#{file.ext('.tex')}}\n\\end{document}")
    File.write("#{build_dir}/main.tex", main_tex)
    # copy or convert the files into build_dir
    cp_conv build_dir
    # Typeset
    cur_dir = Dir.pwd
    cd build_dir
    system "latexmk -lualatex -pdflualatex=\"lualatex --halt-on-error %O %S\" main.tex"
    cd cur_dir
  end

  # example of n_n_n and return value:  '1-1-1' => 'part1/chap1/sec1.src.tex', '1-2' => 'chap1/sec2.md', '1' => 'sec1.tex',
  def num2path n_n_n
    return nil unless n_n_n.is_a? String
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
    srcs = Dir.glob("#{path}.*")
    return nil if srcs.size != 1
    srcs[0]
  end
end