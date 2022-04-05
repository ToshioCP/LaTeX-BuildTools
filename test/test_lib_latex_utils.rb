require 'minitest/autorun'
require '../lib_latex_utils.rb'
include Latex_Utils

module Lib_for_test
  # make directories to write a file like 'dir1/dir2/dir3/file'
  def dfwrite path,content
    return unless path.instance_of? String
    if path.include?('/')
      dirs = path.split('/')
      dirs.pop
      dirs = dirs.inject([]){|ds, d| ds == [] ? ds << d : ds << "#{ds[-1]}/#{d}"}
      dirs.each {|d| Dir.mkdir(d) unless Dir.exist?(d)}
    end
    File.write(path,content)
  end

  def rm_all(dir)
    return unless dir.instance_of?(String)
    if Dir.exist?(dir)
      Dir.each_child(dir) do |d|
        if Dir.exist?("#{dir}/#{d}")
          rm_all("#{dir}/#{d}")
        else
          File.delete("#{dir}/#{d}")
        end
      end
      Dir.rmdir(dir)
    elsif File.exist?(dir)
      File.delete(dir)
    end
  end

  def create_1 dir
    a = 'a.tex'; b = 'b.png'; c = 'image/c.jpg'; d = 'tex/d.tex'
    files_pcs = [
      ['part1/chap1/sec1.src.tex', <<~"EOS"
      \\input{#{a}}
      \\includegraphics[width=8cm]{#{b}}
      %\\input{#{a}}
      \\begin{verbatim}
      \\includegraphics{#{b}}
      \\end{verbatim}
      EOS
      ],
      ['part1/chap1/sec2.src.tex', 'sec2.src.tex'],
      ['part1/chap2/sec1.src.tex', 'sec1.src.tex'],
      ['part1/chap3/sec1.src.tex', 'sec1.src.tex'],
      ['part2/chap1/sec1.tex', 'sec1.tex'],
      ['part2/chap1/sec2.5.tex', 'sec2.5.tex'],
      ['part2/chap2/sec1.tex', 'sec1.tex'],
      ['part2/chap2/sec3.tex', 'sec3.tex'],
      ['part2/chap3/sec1.md', <<~"EOS"
      #### introduction

      Lib\\_Latex\\_Utils is a library.
      ![photo](#{c})
      EOS
      ],
      ['part2/chap3/sec2.md', 'sec2.md']
    ]
    main = <<~'EOS'
    \documentclass{ltjsbook}
    \input{helper.tex}
    \title{代数学}
    \author{関谷　敏雄}
    \begin{document}
    \frontmatter
    \begin{titlepage}
    \input{cover.tex}
    \end{titlepage}
    \tableofcontents
    \mainmatter

    \end{document}
    EOS
    dfwrite("#{dir}/#{a}", "\\input{#{d}}\n")
    dfwrite("#{dir}/#{b}",''); dfwrite("#{dir}/#{c}",'')
    dfwrite("#{dir}/#{d}","\\includegraphics{#{c}}")
    abs_a = File.absolute_path("#{dir}/#{a}")
    abs_b = File.absolute_path("#{dir}/#{b}")
    abs_c = File.absolute_path("#{dir}/#{c}")
    abs_d = File.absolute_path("#{dir}/#{d}")
    files_pcs.each{|f,c| dfwrite("#{dir}/#{f}",c)}
    File.write("#{dir}/main.tex",main)
    File.write("#{dir}/helper.tex",'')
    File.write("#{dir}/cover.tex",'')
    {a:a,b:b,c:c,d:d,abs_a:abs_a,abs_b:abs_b,abs_c:abs_c,abs_d:abs_d}
  end
  def create_2 dir
    a = 'a.tex'; b = 'b.png'; c = 'image/c.jpg'; d = 'tex/d.tex'
    files_cs = [
      ['chap1/sec1.src.tex', <<~"EOS"
      \\input{#{a}}
      \\includegraphics[width=8cm]{#{b}}
      %\\input{#{a}}
      \\begin{verbatim}
      \\includegraphics{#{b}}
      \\end{verbatim}
      EOS
      ],
      ['chap1/sec2.src.tex', 'sec2.src.tex'],
      ['chap2/sec1.src.tex', 'sec1.src.tex'],
      ['chap3/sec1.md', 'sec1.md'],
      ['chap3/sec2.md', <<~"EOS"
      #### introduction

      Lib\\_Latex\\_Utils is a library.
      ![photo](#{c})
      EOS
      ]
    ]
    dfwrite("#{dir}/#{a}", "\\input{#{d}}\n")
    dfwrite("#{dir}/#{b}",''); dfwrite("#{dir}/#{c}",'')
    dfwrite("#{dir}/#{d}","\\includegraphics{#{c}}")
    abs_a = File.absolute_path("#{dir}/#{a}")
    abs_b = File.absolute_path("#{dir}/#{b}")
    abs_c = File.absolute_path("#{dir}/#{c}")
    abs_d = File.absolute_path("#{dir}/#{d}")
    files_cs.each{|f,c| dfwrite("#{dir}/#{f}",c)}
    {a:a,b:b,c:c,d:d,abs_a:abs_a,abs_b:abs_b,abs_c:abs_c,abs_d:abs_d}
  end
  def create_3 dir
    a = 'a.tex'; b = 'b.png'; c = 'image/c.jpg'; d = 'tex/d.tex'
    files_s = [
      ['sec1.src.tex', <<~"EOS"
      \\input{#{a}}
      \\includegraphics[width=8cm]{#{b}}
      %\\input{#{a}}
      \\begin{verbatim}
      \\includegraphics{#{b}}
      \\end{verbatim}
      EOS
      ],
      ['sec2.src.tex', 'src.tex'],
      ['sec3.md', <<~"EOS"
      #### introduction

      Lib\\_Latex\\_Utils is a library.
      ![photo](#{c})
      EOS
      ]
    ]
    dfwrite("#{dir}/#{a}", "\\input{#{d}}\n")
    dfwrite("#{dir}/#{b}",''); dfwrite("#{dir}/#{c}",'')
    dfwrite("#{dir}/#{d}","\\includegraphics{#{c}}")
    abs_a = File.absolute_path("#{dir}/#{a}")
    abs_b = File.absolute_path("#{dir}/#{b}")
    abs_c = File.absolute_path("#{dir}/#{c}")
    abs_d = File.absolute_path("#{dir}/#{d}")
    files_s.each{|f,c| dfwrite("#{dir}/#{f}",c)}
    {a:a,b:b,c:c,d:d,abs_a:abs_a,abs_b:abs_b,abs_c:abs_c,abs_d:abs_d}
  end
end

class TestLibLatexUtils < Minitest::Test
  include Lib_for_test
  def setup
    # These three samples must not be changed.
    @temp1 = "temp1"+get_temp_name()
    @temp2 = "temp2"+get_temp_name()
    @temp3 = "temp3"+get_temp_name()
    @p1 = create_1(@temp1)
    @p2 = create_2(@temp2)
    @p3 = create_3(@temp3)
    if File.file?("../converter.rb")
      add_conv(eval(File.read("../converter.rb")))
    end
  end

  def teardown
    rm_all(@temp1); rm_all(@temp2); rm_all(@temp3)
  end

  def test_get_suffix
    assert_equal 'tex', get_suffix('sec1.tex')
    assert_equal 'src.tex', get_suffix('sec1.src.tex')
    assert_equal 'md', get_suffix('sec1.md')
  end
  def test_conv
    p1c1s1_expected = <<~"EOS"
    \\input{#{@p1[:abs_a]}}
    \\includegraphics[width=8cm]{#{@p1[:abs_b]}}
    %\\input{#{@p1[:a]}}
    \\begin{verbatim}
    \\includegraphics{#{@p1[:b]}}
    \\end{verbatim}
    EOS
    p2c3s1_expected = <<~"EOS"
    \\hypertarget{introduction}{%
    \\paragraph{introduction}\\label{introduction}}

    Lib\\_Latex\\_Utils is a library. \\includegraphics{#{@p1[:abs_c]}}
    EOS
    c1s1_expected = <<~"EOS"
    \\input{#{@p2[:abs_a]}}
    \\includegraphics[width=8cm]{#{@p2[:abs_b]}}
    %\\input{#{@p2[:a]}}
    \\begin{verbatim}
    \\includegraphics{#{@p2[:b]}}
    \\end{verbatim}
    EOS
    c3s2_expected = <<~"EOS"
    \\hypertarget{introduction}{%
    \\paragraph{introduction}\\label{introduction}}

    Lib\\_Latex\\_Utils is a library. \\includegraphics{#{@p2[:abs_c]}}
    EOS
    s1_expected = <<~"EOS"
    \\input{#{@p3[:abs_a]}}
    \\includegraphics[width=8cm]{#{@p3[:abs_b]}}
    %\\input{#{@p3[:a]}}
    \\begin{verbatim}
    \\includegraphics{#{@p3[:b]}}
    \\end{verbatim}
    EOS
    s3_expected = <<~"EOS"
    \\hypertarget{introduction}{%
    \\paragraph{introduction}\\label{introduction}}

    Lib\\_Latex\\_Utils is a library. \\includegraphics{#{@p3[:abs_c]}}
    EOS
    result = "sec1_#{get_temp_name()}.tex"
    conv(@temp1, "part1/chap1/sec1.src.tex", result)
    actual = File.read(result)
    File.delete(result)
    assert_equal p1c1s1_expected, actual, "conv didn't work."
    conv(@temp1, "part2/chap3/sec1.md", result)
    actual = File.read(result)
    File.delete(result)
    assert_equal p2c3s1_expected, actual, "conv didn't work."
    conv(@temp2, "chap1/sec1.src.tex", result)
    actual = File.read(result)
    File.delete(result)
    assert_equal c1s1_expected, actual, "conv didn't work."
    conv(@temp2, "chap3/sec2.md", result)
    actual = File.read(result)
    File.delete(result)
    assert_equal c3s2_expected, actual, "conv didn't work."
    conv(@temp3, "sec1.src.tex", result)
    actual = File.read(result)
    File.delete(result)
    assert_equal s1_expected, actual, "conv didn't work."
    conv(@temp3, "sec3.md", result)
    actual = File.read(result)
    File.delete(result)
    assert_equal s3_expected, actual, "conv didn't work."
  end
  def test_get_graphics_files
    assert_equal ["#{@p1[:b]}"], get_graphics_files(@temp1, "part1/chap1/sec1.src.tex")
    assert_equal ["#{@p1[:c]}"], get_graphics_files(@temp1, "part2/chap3/sec1.md")
    assert_equal ["#{@p2[:b]}"], get_graphics_files(@temp2, "chap1/sec1.src.tex")
    assert_equal ["#{@p2[:c]}"], get_graphics_files(@temp2, "chap3/sec2.md")
    assert_equal ["#{@p3[:b]}"], get_graphics_files(@temp3, "sec1.src.tex")
    assert_equal ["#{@p3[:c]}"], get_graphics_files(@temp3, "sec3.md")
  end
  def test_get_input_files
    assert_equal ["#{@p1[:a]}"], get_input_files(@temp1, "part1/chap1/sec1.src.tex")
    assert_equal ["#{@p2[:a]}"], get_input_files(@temp2, "chap1/sec1.src.tex")
    assert_equal ["#{@p3[:a]}"], get_input_files(@temp3, "sec1.src.tex")
  end
  def test_get_input_files_recursively
    assert_equal ["#{@p1[:a]}","#{@p1[:d]}"], get_input_files_recursively(@temp1, "part1/chap1/sec1.src.tex")
    assert_equal ["#{@p2[:a]}","#{@p2[:d]}"], get_input_files_recursively(@temp2, "chap1/sec1.src.tex")
    assert_equal ["#{@p3[:a]}","#{@p3[:d]}"], get_input_files_recursively(@temp3, "sec1.src.tex")
  end
  def test_get_input_files_from_files
    files = ["part1/chap1/sec1.src.tex", "main.tex"]
    assert_equal ["#{@p1[:a]}","helper.tex","cover.tex"], get_input_files_from_files(@temp1, files)
  end
  def test_renum_src_files
    renum_dir = get_temp_name()
    create_1(renum_dir)
    renum_src_files(renum_dir)
    files = get_src_paths(renum_dir)
    files_expected = [
      "part1/chap1/sec1.src.tex",
      "part1/chap1/sec2.src.tex",
      "part1/chap2/sec1.src.tex",
      "part1/chap3/sec1.src.tex",
      "part2/chap1/sec1.tex",
      "part2/chap1/sec2.tex",
      "part2/chap2/sec1.tex",
      "part2/chap2/sec2.tex",
      "part2/chap3/sec1.md",
      "part2/chap3/sec2.md",
    ]
    rm_all(renum_dir)
    assert_equal files_expected, files
  end
  def test_get_src_paths
    files = get_src_paths(@temp1)
    files_expected = [
      "part1/chap1/sec1.src.tex",
      "part1/chap1/sec2.src.tex",
      "part1/chap2/sec1.src.tex",
      "part1/chap3/sec1.src.tex",
      "part2/chap1/sec1.tex",
      "part2/chap1/sec2.5.tex",
      "part2/chap2/sec1.tex",
      "part2/chap2/sec3.tex",
      "part2/chap3/sec1.md",
      "part2/chap3/sec2.md",
    ]
    assert_equal files_expected, files
    files = get_src_paths(@temp2)
    files_expected = [
      "chap1/sec1.src.tex",
      "chap1/sec2.src.tex",
      "chap2/sec1.src.tex",
      "chap3/sec1.md",
      "chap3/sec2.md"
    ]
    assert_equal files_expected, files
    files = get_src_paths(@temp3)
    files_expected = [
      "sec1.src.tex",
      "sec2.src.tex",
      "sec3.md"
    ]
    assert_equal files_expected, files
  end
  def test_get_src_dst_pairs
    pairs = get_src_dst_pairs(@temp1)
    pairs_expected = [
      [ "part1/chap1/sec1.src.tex", "subfile1.tex"],
      [ "part1/chap1/sec2.src.tex", "subfile2.tex"],
      [ "part1/chap2/sec1.src.tex", "subfile3.tex"],
      [ "part1/chap3/sec1.src.tex", "subfile4.tex"],
      [ "part2/chap1/sec1.tex", "subfile5.tex"],
      [ "part2/chap1/sec2.5.tex", "subfile6.tex"],
      [ "part2/chap2/sec1.tex", "subfile7.tex"],
      [ "part2/chap2/sec3.tex", "subfile8.tex"],
      [ "part2/chap3/sec1.md", "subfile9.tex"],
      [ "part2/chap3/sec2.md", "subfile10.tex"]
    ]
    assert_equal pairs_expected, pairs
    pairs = get_src_dst_pairs(@temp2)
    pairs_expected = [
      [ "chap1/sec1.src.tex", "subfile1.tex"],
      [ "chap1/sec2.src.tex", "subfile2.tex"],
      [ "chap2/sec1.src.tex", "subfile3.tex"],
      [ "chap3/sec1.md", "subfile4.tex"],
      [ "chap3/sec2.md", "subfile5.tex"]
    ]
    assert_equal pairs_expected, pairs
    pairs = get_src_dst_pairs(@temp3)
    pairs_expected = [
      [ "sec1.src.tex", "subfile1.tex"],
      [ "sec2.src.tex", "subfile2.tex"],
      [ "sec3.md", "subfile3.tex"]
    ]
    assert_equal pairs_expected, pairs
  end
  def test_mk_main_temp
    build_dir = get_temp_name()
    Dir.mkdir(build_dir)
    helper_tex = File.realpath("#{@temp1}/helper.tex")
    cover_tex = File.realpath("#{@temp1}/cover.tex")
    files = [
      "part1/chap1/sec1.src.tex",
      "part1/chap1/sec2.src.tex",
      "part1/chap2/sec1.src.tex",
      "part1/chap3/sec1.src.tex",
      "part2/chap1/sec1.tex",
      "part2/chap1/sec2.5.tex",
      "part2/chap2/sec1.tex",
      "part2/chap2/sec3.tex",
      "part2/chap3/sec1.md",
      "part2/chap3/sec2.md",
    ]
    mk_main_temp @temp1, build_dir, files
    mk_temp = File.read("#{build_dir}/main_temp.tex")
    main_temp_expected = <<~"EOS"
    \\documentclass{ltjsbook}
    \\input{#{helper_tex}}
    \\title{代数学}
    \\author{関谷　敏雄}
    \\begin{document}
    \\frontmatter
    \\begin{titlepage}
    \\input{#{cover_tex}}
    \\end{titlepage}
    \\tableofcontents
    \\mainmatter

    \\input{part1/chap1/sec1.src.tex}
    \\input{part1/chap1/sec2.src.tex}
    \\input{part1/chap2/sec1.src.tex}
    \\input{part1/chap3/sec1.src.tex}
    \\input{part2/chap1/sec1.tex}
    \\input{part2/chap1/sec2.5.tex}
    \\input{part2/chap2/sec1.tex}
    \\input{part2/chap2/sec3.tex}
    \\input{part2/chap3/sec1.md}
    \\input{part2/chap3/sec2.md}

    \\end{document}
    EOS
    rm_all(build_dir)
    assert_equal main_temp_expected, mk_temp
  end
  def test_num2path
    assert_equal "part1/chap2/sec1.src.tex", num2path("1-2-1",@temp1)
    assert_equal "chap1/sec2.src.tex", num2path("1-2",@temp2)
    assert_equal "sec3.md", num2path("3",@temp3)
  end
  def test_path2num
    assert_equal "1-2-1", path2num("part1/chap2/sec1.src.tex")
    assert_equal "1-2", path2num("chap1/sec2.src.tex")
    assert_equal "2", path2num("sec2.src.tex")
  end

end
