require_relative 'utils.rb'

module Lbt
  # Typeset one source file to check the PDF.
  #
  # Parameter:
  # [file_or_number]
  # It can be either a filename or the number of a filename.
  # For example, part1/chap2/sec3.tex or 1-2-3
  def part_typeset file_or_number
    return unless file_or_number.is_a? String
    if File.file?(file_or_number)
      file = file_or_number
    else
      file = num2path(file_or_number)
      return unless File.file? file
    end

    m = get_config[:'build_dir']
    build_dir = m ? m : "_build"
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

  # :nodoc:
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