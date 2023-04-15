require 'minitest/autorun'
require_relative '../lib/lbt/part_typeset.rb'
require_relative '../lib/lbt/create.rb'

class TestNum2Path < Minitest::Test
  include Lbt
  def setup
    @cur_dir = Dir.pwd
    cd __dir__
    mkdir_p "num2path/part1/chap2"
    mkdir_p "num2path/chap1"
    touch "num2path/part1/chap2/sec1.tex"
    touch "num2path/chap1/sec2.tex"
    touch "num2path/sec3.md"
    cd "num2path"
  end
  def teardown
    cd __dir__
    remove_entry_secure "num2path"
    cd @cur_dir
  end
  def test_num2path
    assert_equal "part1/chap2/sec1.tex", num2path("1-2-1")
    assert_equal "chap1/sec2.tex", num2path("1-2")
    assert_equal "sec3.md", num2path("3")
  end
end