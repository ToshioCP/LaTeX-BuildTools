require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/lbt/utils.rb'
include FileUtils

include Lbt

class TestUtils2 < Minitest::Test
  # This test changes the current directory.
  # It affects other tests.
  # So, it must be separated from them.
  def setup
    @cur_dir = Dir.pwd
    @dir = "#{__dir__}/cp_conv"
    mkdir @dir
    cd @dir
  end
  def teardown
    cd @cur_dir
    remove_entry_secure @dir
  end

  def test_cp_conv
    dirs = ["part1/chap1", "part1/chap2", "part2/chap1", "part2/chap2"]
    dirs.each {|d| mkdir_p(d)}
    files = dirs.map {|d| ["#{d}/sec1.md", "#{d}/sec2.tex"]}.flatten + ["main.tex", "helper.tex"]
    files.each {|f| touch(f)}
    mkdir "_build"
    cp_conv "_build"
    files = files.map{|f| f.sub(/^/, "_build/")}.map{|f| File.extname(f) == ".md" ? f.ext(".tex") : f}
    files.each do |f|
      if f =~ /main.tex$/
        refute File.exist?(f), "File #{f} is expected not to be exist but it exists."
      else
        assert File.exist?(f), "File #{f} is expected to exist but not it exists."
      end
    end
  end
end