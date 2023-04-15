require 'fileutils'
require 'base64'

module Lbt
=begin rdoc
The create method creates a source file directory and put some templates in the directory.

Parameters are:

[dir] The name of the source file directory
[document\_class] The document class of the LaTeX source file. For example, article, book and beamer.
[build\_dir] The working directory in which typeset is carried out.
=end
  def create dir, document_class="book", build_dir="_build"
    raise "Argument error." unless dir.is_a?(String) && dir =~ /[[:^space:]]+/
    raise "#{dir} already exists." if Dir.exist?(dir)
    mkdir_p(dir)
    File.write("#{dir}/.config", "build_dir = #{build_dir}\n")
    helper_tex = <<~EOS
    \\usepackage{amsmath,amssymb}
    \\usepackage[luatex]{graphicx}
    \\usepackage{tikz}
    \\usepackage[margin=2.4cm]{geometry}
    \\usepackage[colorlinks=true,linkcolor=black]{hyperref}
    % If your source includes Markdown, you probably need the following lines.
    % It is because Pandoc generates some undefined commands.
    % The Pandoc template file shows how to define them.
    % You can see it by 'pandoc --print-default-template=latex'.
    \\providecommand{\\tightlist}{%
      \\setlength{\\itemsep}{0pt}\\setlength{\\parskip}{0pt}}
    EOS

    if ["book", "ltjsbook"].include? document_class
        main_tex = <<~EOS
        \\documentclass{#{document_class}}
        \\input{helper.tex}
        \\title{Title}
        \\author{Author}
        \\begin{document}
        \\frontmatter
        \\begin{titlepage}
        \\input{cover.tex}
        \\end{titlepage}
        \\tableofcontents
        \\mainmatter

        \\end{document}
      EOS

      cover_tex = <<~EOS
        \\newgeometry{margin=2.4cm}
        \\begin{center}
        \\begin{tikzpicture}
          \\node at (0,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (70pt,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (140pt,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (210pt,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (280pt,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (350pt,0) {\\includegraphics[width=100pt]{gecko.png}};
        \\end{tikzpicture}
        \\end{center}

        \\vspace{2cm}
        \\begin{center}
        {\\fontsize{64}{0} \\selectfont Title}
        \\end{center}
        \\vspace{1cm}
        \\begin{center}
        {\\huge Author}
        \\end{center}

        \\vspace{9cm}
        %\\vspace{6.5cm}
        %\\begin{center}
        %{\\Large Foobar University}
        %\\end{center}
        %\\begin{center}
        %{\\Large School of Foobar}
        %\\end{center}

        \\vspace{3cm}
        \\begin{center}
        \\begin{tikzpicture}
          \\node at (0,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (70pt,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (140pt,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (210pt,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (280pt,0) {\\includegraphics[width=100pt]{gecko.png}};
          \\node at (350pt,0) {\\includegraphics[width=100pt]{gecko.png}};
        \\end{tikzpicture}
        \\end{center}
        \\restoregeometry
      EOS

      File.write("#{dir}/main.tex", main_tex)
      File.write("#{dir}/helper.tex", helper_tex)
      File.write("#{dir}/cover.tex", cover_tex)
      gecko_png = __dir__+"/../../images/gecko.png"
      cp(gecko_png, "#{dir}/gecko.png")
    elsif ["article", "ltjsarticle"].include? document_class
      main_tex = <<~EOS
      \\documentclass{#{document_class}}
      \\input{helper.tex}
      \\title{Title}
      \\author{Author}
      \\begin{document}
      \\maketitle
      \\tableofcontents

      \\end{document}
      EOS
      File.write("#{dir}/main.tex", main_tex)
      File.write("#{dir}/helper.tex", helper_tex)
    elsif document_class == "beamer"
      main_tex = <<~EOS
      \\documentclass[utf8,aspectratio=149]{beamer}
      \\mode<presentation>
      {
        \\usetheme{Warsaw}
        \\setbeamercovered{transparent}
      }
      \\input{helper.tex}
      % Don't show navigation symbol => If you want to show it, comment out the following line.
      \\setbeamertemplate{navigation symbols}{}
      \\title[short\\_title] % (optional, use only with long paper titles)
      {titile}
      \\subtitle
      {substitile}
      \\author[short\\_author] % (optional, use only with lots of authors)
      {author \\\\ \\texttt{sample\\_address@email.com}}
      % - Give the names in the same order as the appear in the paper.
      % - Use the \\inst{?} command only if the authors have different
      %   affiliation.
      \\institute[short\\_institute] % (optional, but mostly needed)
      {
      %  \\inst{1}%
        Department of Mathematics and Technology\\\\
        School of Education and Humanities\\\\
        XXXX University
      }
      % - Use the \\inst command only if there are several affiliations.
      % - Keep it simple, no one is interested in your street address.
      \\date[short\\_date] % (optional, should be abbreviation of conference name)
      {XXXX meeting on Wednesday, April 27 2022}
      % - Either use conference name or its abbreviation.
      % - Not really informative to the audience, more for people (including
      %   yourself) who are reading the slides online
      \\subject{subject}
      % If you have a file called "university-logo-filename.xxx", where xxx
      % is a graphic format that can be processed by lualatex,
      % resp., then you can add a logo as follows:
      % \\pgfdeclareimage[height=0.5cm]{university-logo}{university-logo-filename}
      % \\logo{\\pgfuseimage{university-logo}}
      \\begin{document}
      \\begin{frame}
        \\titlepage
      \\end{frame}
      \\begin{frame}{Outline}
        \\tableofcontents
      %  \\begin{center}
      %    \\includegraphics[width=6cm,keepaspectratio]{photo.jpg}
      %  \\end{center}
      \\end{frame}

      \\end{document}
      EOS
      helper_tex = <<~EOS
      \\usepackage{luatexja}
      % 和文のデフォルトをゴシック体に
      \\renewcommand{\\kanjifamilydefault}{\\gtdefault}
      \\usepackage{amsmath,amssymb}
      \\usepackage{tikz}
      \\usepackage[absolute,overlay]{textpos}
      EOS
      sec1_tex = <<~EOS
      % This is a sample latex file for the beamer documentclass.
      \\begin{frame}{introduction}
      About something
      \\begin{itemize}
        \\item item 1
        \\item<2> item 2
      \\end{itemize}
      About another thing
      \\begin{enumerate}
        \\item<3> item 1
        \\item<3-4> item 2
      \\end{enumerate}
      \\alert{alert message, which is red.}
      \\end{frame}
      % Show a photo that extends to the whole slide view.
      \\begin{frame}
      \\begin{textblock*}{128mm}(0pt,0pt)
      \\includegraphics[width=128mm,height=96mm,keepaspectratio]{lagoon.jpg}
      \\end{textblock*}
      \\end{frame}
      EOS
      File.write("#{dir}/main.tex", main_tex)
      File.write("#{dir}/helper.tex", helper_tex)
      File.write("#{dir}/sec1.tex", sec1_tex)
      lagoon_jpg = __dir__+"/../../images/lagoon.jpg"
      cp(lagoon_jpg, "#{dir}/lagoon.jpg")
    else
      main_tex = <<~EOS
      \\documentclass{#{document_class}}
      \\input{helper.tex}
      \\title{Title}
      \\author{Author}
      \\begin{document}
      \\maketitle
      \\tableofcontents

      \\end{document}
      EOS
      File.write("#{dir}/main.tex", main_tex)
      File.write("#{dir}/helper.tex", helper_tex)
    end
  end
end