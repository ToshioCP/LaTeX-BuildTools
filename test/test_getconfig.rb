require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/lbt/utils.rb'
include FileUtils

include Lbt

class TestGetConfig < Minitest::Test
  def setup
    @cur_dir = Dir.pwd
    @dir = "#{__dir__}/get_config"
    mkdir @dir
    cd @dir
  end
  def teardown
    cd @cur_dir
    remove_entry_secure @dir
  end

  def test_getconfig
    File.write(".config", <<~EOS)
    build_dir = _build
    top-level-division = chapter
    EOS
    assert_equal({'build_dir': "_build", 'top-level-division': "chapter"}, get_config)
  end
end