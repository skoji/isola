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

  def test_initialize_2
    f = ::Isola::FileHandler.new(File.join(FIXTURES_DIR, "dir_with_include"))
    files = f.pages
    assert_equal 1, files.size, files
    assert_equal files["main"], "main.md", files

    layouts = f.layouts
    assert_equal 2, layouts.size, layouts
    assert_equal layouts["base"], "_layouts/base.html.erb", layouts
    assert_equal layouts["page"], "_layouts/page.html.erb", layouts

    includes = f.includes
    assert_equal 1, includes.size, includes
    assert_equal includes["head"], "_includes/head.html.erb", includes
  end
end
