require 'minitest/autorun'
require_relative '../lib/lbt/renumber.rb'
require "fileutils"

class TestRenumber < Minitest::Test
  include Lbt
  include FileUtils
  def setup
    @files1_o = [
      "part1/chap1.5/sec0.1.md",
      "part1/chap1.5/sec1.2.md",
      "part1/chap3/sec5.tex",
      "part1/chap3/sec5.7.tex",
      "part3.2/chap1.2/sec2.1.md",
      "part3.2/chap1.2/sec3.2.tex",
      "part3.2/chap1.2/sec5.md",
      "part3.2/chap2.1/sec2.tex"
    ]
    @files1_n = [
      "part1/chap1/sec1.md",
      "part1/chap1/sec2.md",
      "part1/chap2/sec1.tex",
      "part1/chap2/sec2.tex",
      "part2/chap1/sec1.md",
      "part2/chap1/sec2.tex",
      "part2/chap1/sec3.md",
      "part2/chap2/sec1.tex"
    ]
    @files2_o = [
      "chap1.5/sec1.1.md",
      "chap1.5/sec1.2.md",
      "chap3/sec2.3.tex",
      "chap3/sec2.4.tex",
      "chap4.2/sec2.1.md",
      "chap4.2/sec2.2.tex",
      "chap4.2/sec2.23.md",
      "chap6/sec100.tex"
    ]
    @files2_n = [
      "chap1/sec1.md",
      "chap1/sec2.md",
      "chap2/sec1.tex",
      "chap2/sec2.tex",
      "chap3/sec1.md",
      "chap3/sec2.tex",
      "chap3/sec3.md",
      "chap4/sec1.tex"
    ]
    @files3_o = [
      "sec0.1.md",
      "sec1.tex",
      "sec2.3.md",
      "sec2.35.md",
      "sec301.tex",
      "sec302.md"
    ]
    @files3_n = [
      "sec1.md",
      "sec2.tex",
      "sec3.md",
      "sec4.md",
      "sec5.tex",
      "sec6.md"
    ]
    @cur_dir = Dir.pwd
    @dir = "#{__dir__}/renumber_sample"
    mkdir @dir
    cd @dir
  end
  def teardown
    cd @cur_dir
    remove_entry_secure @dir
  end

  def test_renum
    @files1_o.each do |f|
      mkdir_p File.dirname(f)
      touch f
    end
    renum
    @files1_n.each do |f|
      assert File.exist?(f), "File #{f} not exists."
    end
    remove_entry_secure "part1"
    remove_entry_secure "part2"

    @files2_o.each do |f|
      mkdir_p File.dirname(f)
      touch f
    end
    renum
    @files2_n.each do |f|
      assert File.exist?(f), "File #{f} not exists."
    end
    remove_entry_secure "chap1"
    remove_entry_secure "chap2"
    remove_entry_secure "chap3"
    remove_entry_secure "chap4"

    @files3_o.each do |f|
      touch f
    end
    renum
    @files3_n.each do |f|
      assert File.exist?(f), "File #{f} not exists."
    end
  end
end
