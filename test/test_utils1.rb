require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/lbt/utils.rb'
include FileUtils

class TestUtils < Minitest::Test
  def test_remove_tex_comment
    tex_string = <<~EOS
    \\documentclass{article}
    \\input{helper.tex}
    \\title{Example}
    \\author{Toshio Sekiya}
    \\begin{document}
    \\maketitle
    \\tableofcontents
    \\section{Sample}%section heading

    The following is a sample program.
    \\begin{verbatim}
    s = File.read("sample.rb")
    File.write("backup.rb", s)
    \\end{verbatim}%
    It just copies a file.
    % The end of the document.
    \\end{document}
    EOS
    tex_string_removed = <<~EOS
    \\documentclass{article}
    \\input{helper.tex}
    \\title{Example}
    \\author{Toshio Sekiya}
    \\begin{document}
    \\maketitle
    \\tableofcontents
    \\section{Sample}
    The following is a sample program.
    It just copies a file.
    \\end{document}
    EOS
    assert_equal tex_string_removed, tex_string.remove_tex_comment
  end
  def test_ext
    s = "sec1.tex"
    assert_equal "sec1.md", s.ext(".md")
    s = "part1/chap2/sec3.md"
    assert_equal "part1/chap2/sec3.html", s.ext(".html")
  end
  def test_pcs
    dirs = ["part1/chap1", "part1/chap2", "part2/chap1", "part2/chap2"].map{|d| "pcs/#{d}"}
    dirs.each {|d| mkdir_p(d)}
    files = dirs.map {|d| ["#{d}/sec1.md", "#{d}/sec2.tex"]}.flatten
    files.each {|f| touch(f)}
    pcs = Lbt::PCS.new "pcs"
    assert_equal :PCS, pcs.type
    assert_equal "pcs", pcs.dir
    files = files.map{|d| d.sub(/^pcs\//, "")}
    assert_equal files, pcs.to_a
    pcs_files = []
    pcs.each {|f| pcs_files << f}
    assert files == pcs_files
    remove_entry_secure "pcs"

    dirs = ["chap1", "chap2"].map{|d| "pcs/#{d}"}
    dirs.each {|d| mkdir_p(d)}
    files = dirs.map {|d| ["#{d}/sec1.md", "#{d}/sec2.tex"]}.flatten
    files.each {|f| touch(f)}
    pcs = Lbt::PCS.new "pcs"
    assert_equal :CS, pcs.type
    assert_equal "pcs", pcs.dir
    files = files.map{|d| d.sub(/^pcs\//, "")}
    assert_equal files, pcs.to_a
    pcs_files = []
    pcs.each {|f| pcs_files << f}
    assert files == pcs_files
    remove_entry_secure "pcs"

    mkdir_p "pcs"
    touch "pcs/sec1.md"
    touch "pcs/sec2.tex"
    files = ["sec1.md", "sec2.tex"]
    pcs = Lbt::PCS.new "pcs"
    assert_equal :S, pcs.type
    assert_equal "pcs", pcs.dir
    assert_equal files, pcs.to_a
    pcs_files = []
    pcs.each {|f| pcs_files << f}
    assert files == pcs_files
    remove_entry_secure "pcs"
  end
  include Lbt
  def test_get_converters
    converter = "{'.txt': lambda {|src, dst| cp(src, dst)}}\n"
    File.write("converters.rb", converter)
    converters = get_converters
    assert_equal converters[:'.txt'].source_location, ["(eval)", 1]
    assert_equal converters[:'.md'].source_location, [File.absolute_path("../lib/lbt/utils.rb"), 86]
    rm "converters.rb"
  end
end