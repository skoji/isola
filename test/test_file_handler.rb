# frozen_string_literal: true

require "test_helper"

class TestFileHandler < Minitest::Test
  def test_initialize
    f = ::Isola::FileHandler.new(File.join(FIXTURES_DIR, "simple_dir"))
    files = f.instance_eval { @files_to_process }
    assert_equal 2, files.size, files
    assert files.include?("index.md")
    assert files.include?("another_page.md.erb")
  end
end
