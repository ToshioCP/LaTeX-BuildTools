require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/lbt/utils.rb'
include FileUtils

include Lbt

class TestUtils < Minitest::Test
  # This test changes the current directory.
  # It affects other tests.
  # So, it must be separated from them.
  def test_cp_conv
    dirs = ["part1/chap1", "part1/chap2", "part2/chap1", "part2/chap2"].map{|d| "cp_conv/#{d}"}
    dirs.each {|d| mkdir_p(d)}
    files = dirs.map {|d| ["#{d}/sec1.md", "#{d}/sec2.tex"]}.flatten + ["main.tex", "helper.tex"].map{|d| "cp_conv/#{d}"}
    files.each {|f| touch(f)}
    mkdir "cp_conv/_build"
    cur_dir = Dir.pwd
    cd "cp_conv"
    cp_conv "_build"
    files = files.map{|f| f.sub(/^cp_conv/, "_build")}.map{|f| File.extname(f) == ".md" ? f.ext(".tex") : f}
    files.each do |f|
      if f =~ /main.tex$/
        refute File.exist?(f), "File #{f} is expected not to be exist but it exists."
      else
        assert File.exist?(f), "File #{f} is expected to exist but not it exists."
      end
    end
    cd cur_dir
    remove_entry_secure "cp_conv"
  end
end