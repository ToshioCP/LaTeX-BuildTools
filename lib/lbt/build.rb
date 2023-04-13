require_relative 'utils.rb'

module Lbt
  def build
    m = File.read(".config").match(/^build_dir = (.*)$/)
    build_dir = m[1] ? m[1] : "_build"
    raise "main.tex not exist." unless File.exist?('main.tex')
    mkdir build_dir unless Dir.exist?(build_dir)

    # Build main.tex
    main_tex = File.read('main.tex')
    m = /\\title(\[(.*?)\])?\s*\{(.*?)\}/.match(main_tex.remove_tex_comment)
    # Beamer has \title[short title]{title} command.
    # Other documentclasses don't have such short style option.
    title = m[2] || m[3]
    files = PCS.new.to_a
    input_commands = files.map{|f| "\\input{#{f.ext('.tex')}}\n"}.flatten.join
    main_tex = main_tex.sub(/\\end{document}/, "#{input_commands}\n\\end{document}")
    File.write("#{build_dir}/main.tex", main_tex)
    # copy or convert the files into build_dir
    cp_conv build_dir
    # Typeset
    cur_dir = Dir.pwd
    cd build_dir
    system "latexmk -lualatex -pdflualatex=\"lualatex --halt-on-error %O %S\" main.tex"
    cd cur_dir
    
    # Copy the pdf file.
    temp = "#{build_dir}/main.pdf"
    target = "#{title}.pdf"
    unless File.exist?(target) && File.mtime(temp) <= File.mtime(target)
      cp temp, target
    end
  end
end