require 'minitest/autorun'
require 'fileutils'
include FileUtils

# Test ../bin/lbt

class TestLbt < Minitest::Test
  def setup
    # set stub lbt library for the test.
    @bin = "#{__dir__}/../bin"
    @cur_dir = Dir.pwd
    @dir = "lbt_sample"
    mkdir_p @dir
    cd @dir
    File.write("lbt.rb", <<~'EOS')
    module Lbt
      %w{build create part_typeset renum}.each do |m|
        eval "def #{m}(*arg); print \"#{m} \#{arg}\"; end"
      end
    end
    EOS
  end
  def teardown
    cd @cur_dir
    remove_entry_secure @dir
  end

  def test_lbt
    [
      ["new sample", "create [\"sample\"]"],
      ["new sample article", "create [\"sample\", \"article\"]"],
      ["new sample beamer beamer_build", "create [\"sample\", \"beamer\", \"beamer_build\"]"],
      ["build", "build []"],
      ["part_typeset 1-2-3", "part_typeset [\"1-2-3\"]"],
      ["renum", "renum []"]
    ].each do |arg, e|
      assert_equal e, `RUBYLIB=. #{@bin}/lbt #{arg} 2>&1`
    end
  end
end
