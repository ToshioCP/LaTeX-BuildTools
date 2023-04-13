require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/lbt/create.rb'
include FileUtils

class TestCreate < Minitest::Test
  include Lbt
  def test_create
    dir = "create_sample"
    create dir
    %w{.config cover.tex gecko.png helper.tex main.tex}.each do |f|
      assert File.exist?("#{dir}/#{f}")
    end
    s = ""
    File.open("#{dir}/main.tex") {|f| s = f.readline}
    assert_equal "\\documentclass{book}\n", s
    remove_entry_secure dir

    create dir, "article"
    %w{.config helper.tex main.tex}.each do |f|
      assert File.exist?("#{dir}/#{f}")
    end
    %w{cover.tex gecko.png}.each do |f|
      refute File.exist?("#{dir}/#{f}")
    end
    File.open("#{dir}/main.tex") {|f| s = f.readline}
    assert_equal "\\documentclass{article}\n", s
    remove_entry_secure dir

    create dir, "beamer"
    %w{.config helper.tex lagoon.jpg main.tex sec1.tex}.each do |f|
      assert File.exist?("#{dir}/#{f}")
    end
    %w{cover.tex gecko.png}.each do |f|
      refute File.exist?("#{dir}/#{f}")
    end
    File.open("#{dir}/main.tex") {|f| s = f.readline}
    assert_equal "\\documentclass[utf8,aspectratio=149]{beamer}\n", s
    remove_entry_secure dir

    create dir, "ltjsbook", "temp"
    %w{.config cover.tex gecko.png helper.tex main.tex}.each do |f|
      assert File.exist?("#{dir}/#{f}")
    end
    File.open("#{dir}/main.tex") {|f| s = f.readline}
    assert_equal "\\documentclass{ltjsbook}\n", s
    s = File.read("#{dir}/.config")
    assert_equal "build_dir = temp", s
    remove_entry_secure dir
  end
end
