require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/lbt/create.rb'
include FileUtils

class TestCreate < Minitest::Test
  include Lbt
  def setup
    @dir1 = "#{__dir__}/create_sample1"
    @dir2 = "#{__dir__}/create_sample2"
    @dir3 = "#{__dir__}/create_sample3"
    @dir4 = "#{__dir__}/create_sample4"
    create @dir1
    create @dir2, "article"
    create @dir3, "beamer"
    create @dir4, "ltjsbook", "temp"
  end
  def teardown
    remove_entry_secure @dir1
    remove_entry_secure @dir2
    remove_entry_secure @dir3
    remove_entry_secure @dir4
  end

  def test_create
    %w{.config cover.tex gecko.png helper.tex main.tex}.each do |f|
      assert File.exist?("#{@dir1}/#{f}")
    end
    s = ""
    File.open("#{@dir1}/main.tex") {|f| s = f.readline}
    assert_equal "\\documentclass{book}\n", s
 
    %w{.config helper.tex main.tex}.each do |f|
      assert File.exist?("#{@dir2}/#{f}")
    end
    %w{cover.tex gecko.png}.each do |f|
      refute File.exist?("#{@dir2}/#{f}")
    end
    File.open("#{@dir2}/main.tex") {|f| s = f.readline}
    assert_equal "\\documentclass{article}\n", s

    %w{.config helper.tex lagoon.jpg main.tex sec1.tex}.each do |f|
      assert File.exist?("#{@dir3}/#{f}")
    end
    %w{cover.tex gecko.png}.each do |f|
      refute File.exist?("#{@dir3}/#{f}")
    end
    File.open("#{@dir3}/main.tex") {|f| s = f.readline}
    assert_equal "\\documentclass[utf8,aspectratio=169]{beamer}\n", s

    %w{.config cover.tex gecko.png helper.tex main.tex}.each do |f|
      assert File.exist?("#{@dir4}/#{f}")
    end
    File.open("#{@dir4}/main.tex") {|f| s = f.readline}
    assert_equal "\\documentclass{ltjsbook}\n", s
    s = File.read("#{@dir4}/.config")
    assert_equal "build_dir = temp\n", s
  end
end
