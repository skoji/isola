# frozen_string_literal: true

require "test_helper"

class TestFileHandler < Minitest::Test
  def test_initialize
    f = ::Isola::FileHandler.new(File.join(FIXTURES_DIR, "simple_dir"))
    files = f.pages
    assert_equal 2, files.size, files
    assert_equal files["index"], "index.md", files
    assert_equal files["another_page"], "another_page.md.erb", files

    layouts = f.layouts
    assert_equal 1, layouts.size, layouts
    assert_equal layouts["default"], "_layouts/default.html.erb", layouts
  end
end
