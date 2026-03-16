require "test_helper"

class TestWatcher < Minitest::Test
  def test_handle_modified_rebuild
    root_dir = File.join(FIXTURES_DIR, "simple_dir")
    site = ::Isola::Site.new("root_dir: #{root_dir}")
    block_mock = Minitest::Mock.new
    block_mock.expect(:call, nil, ["called!"])
    watcher = ::Isola::Watcher.new(site) { block_mock.call("called!") }
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [])
    site.stub(:rebuild, mock) do
      watcher.handle_changes([File.join(root_dir, "index.md")], [], [])
    end
    block_mock.verify
    mock.verify
  end

  def test_handle_added_rebuild
    root_dir = File.join(FIXTURES_DIR, "simple_dir")
    site = ::Isola::Site.new("root_dir: #{root_dir}")
    watcher = ::Isola::Watcher.new(site)
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [])
    site.stub(:rebuild, mock) do
      watcher.handle_changes([], [File.join(root_dir, "new_file.md")], [])
    end
    mock.verify
  end

  def test_handle_removed_rebuild
    root_dir = File.join(FIXTURES_DIR, "simple_dir")
    site = ::Isola::Site.new("root_dir: #{root_dir}")
    watcher = ::Isola::Watcher.new(site)
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [])
    site.stub(:rebuild, mock) do
      watcher.handle_changes([], [], [File.join(root_dir, "index.md")])
    end
    mock.verify
  end

  def test_handle_modified_not_rebuild
    root_dir = File.join(FIXTURES_DIR, "simple_dir")
    site = ::Isola::Site.new("root_dir: #{root_dir}")
    watcher = ::Isola::Watcher.new(site)
    site.stub(:rebuild, -> { raise "should not be called" }) do
      watcher.handle_changes([File.join(root_dir, "_ignored_file.md")], [], [])
    end
  end
end
