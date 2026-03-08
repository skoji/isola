# frozen_string_literal: true

require "test_helper"

class TestFileHandler < Minitest::Test
  def test_initialize
    f = ::Isola::FileHandler.new(File.join(FIXTURES_DIR, "simple_dir"))
    files = f.instance_eval { @files_to_process }
    assert_equal 2, files.size, files
    assert files.include?("index.md")
    assert files.include?("another_page.md.erb")

    layouts = f.instance_eval { @layouts }
    assert_equal 1, layouts.size, layouts
    assert_equal "default.html.erb", layouts[0]
  end
end
