require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/lbt/create.rb'
require_relative '../lib/lbt/build.rb'
include FileUtils

# Test create.rb in advance.

class TestBuild < Minitest::Test
  include Lbt
  def setup
    @cur_dir = Dir.pwd
    @dir = "#{__dir__}/build_sample"
    create @dir
    cd @dir
  end
  def teardown
    cd @cur_dir
    remove_entry_secure @dir
  end

  def test_build
    %w{part1/chap1 part1/chap2 part2/chap1 part2/chap2}.each {|d| mkdir_p d}
    md = <<~EOS
    # Heading1

    Hello world.

    ## Heading2

    Goodby *everyone*.
    EOS
    tex = <<~EOS
    A quadratic function.
    \\begin{equation}
    y=ax^2+bx+c
    \\end{equation}
    EOS
    %w{part1/chap1/sec1.md part1/chap1/sec2.tex part1/chap2/sec1.tex part2/chap1/sec1.md part2/chap2/sec1.tex}.each do |f|
      if File.extname(f) == ".md"
        File.write(f, md)
      else
        File.write(f, tex)
      end
    end
    build

    # We don't test the contents generated by Pandoc and Lualatex here.
    # We just test the exista of (build_dir)/main.pdf and (title).pdf.
    assert File.exist?("_build/main.pdf"), "_build/main.pdf not created."
    assert File.exist?("Title.pdf"), "Title.pdf not created."
  end
end
